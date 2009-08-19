module HasSearchIndex

  MODELS = []
  ACTIONS_TEXT = { "="        => "est égal à",#"is ",
                   "!="       => "est différent de",#"is not ",
                   "like"     => "contient",#"is like",
                   "not like" => "ne contient pas",#"is not like",
                   ">="       => "est plus grand ou égal à",#"is greater to equal than",
                   "<="       => "est plus petit ou égal à",#"is smaller to equal than",
                   "<"        => "est plus petit que",#"is smaller than",
                   ">"        => "est plus grand que" }#"is greater than" }

  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end

  module ClassMethods
    
    AUTHORIZED_OPTIONS = [ :except_attributes,
                           :only_attributes,
                           :additional_attributes,
                           :only_relationships,
                           :except_relationships,
                           :displayed_attributes,
                           :main_model ]

    ACTIONS = { :string   => string = [ "like", "not like", "=", "!=" ],
                :text     => string,
                :integer  => integer = [ ">=", "<=", ">", "<", "=", "!=" ],
                :date     => integer,
                :datetime => integer,
                :float    => integer,
                :boolean  => [ "=", "!=" ] }

    # method called into all models that implement the plugin 
    # it define search_index class variable based on passed options hash
    def has_search_index( options = {} )
      
      error_prefix = "(Has_search_index) model: #{self.to_s}" # DRY respect when dealing with error messages
      
      HasSearchIndex::MODELS << self.to_s unless HasSearchIndex::MODELS.include?(self.to_s)
      # affect if nil to avoid testing nullity and emptyness
      options[:additional_attributes] ||={}
      options[:only_attributes]       ||=[]
      options[:except_attributes]     ||=[]
      options[:except_relationships]  ||=[]
      options[:only_relationships]    ||=[]
      options[:displayed_attributes]  ||=[]
      options[:main_model]            ||= false

#       puts "-- initialisation de #{self} --"   ##### use this in debug purpose to see when the model call the plugin init

      # check options arg for some errors
      options.keys.each do |key|
        raise ArgumentError, "#{error_prefix} : Unknown option :#{key.to_s}" unless AUTHORIZED_OPTIONS.include?(key)      
      end
      
      # create a hash to store all associations that concerned the current model
      assoc_list = Hash.new
      self.reflect_on_all_associations.each do |assoc|
        assoc_list = assoc_list.merge({ assoc.name => { :class_name => assoc.class_name, :macro => assoc.macro.to_s } }) if assoc.options[:polymorphic].nil? or assoc.options[:polymorphic]==false
      end

      # generate default relationships array if not present into 'options' argument
      # if except_relationships is not empty it will discard relationships from the default relationships array
      if options[:only_relationships].empty?
        logger.warn("#{error_prefix} no relationships defined") if assoc_list.empty?
        options[:relationships] = Array.new
        assoc_list.each_pair do |relationship_name, relationship|
          relationship[:class_name].constantize                                                                                # constantize dependant models
          # filter relationships implementing the plugin 'has_search_index'
          raise "#{error_prefix}: Wrong relationship name '#{relationship_name}', maybe you misspelled it" unless self.new.respond_to?(relationship_name.to_s)
          options[:relationships] << relationship_name if HasSearchIndex::MODELS.include?(relationship[:class_name])
        end
        if !options[:except_relationships].empty?                      # filter it if except_relationships isn't empty
          options[:except_relationships].each do |e|
            options[:relationships].delete(e)
          end
        end
      else
        raise ArgumentError, "#{error_prefix}: Warning you mustn't specify both 'only_relationships' and 'except_relationships'" unless options[:except_relationships].empty?
        options[:only_relationships].each { |relationship_name| model = assoc_list[relationship_name][:class_name].constantize } # constantize dependant models
        options[:relationships] = options[:only_relationships]
      end
      options.delete(:except_relationships)
      options.delete(:only_relationships)
      
      # permit to replace attribute name by an object containing sql informations such as name, type, etc...
      tmp = Hash.new
      if options[:only_attributes].empty?
        self.columns.each do |element|
          tmp = tmp.merge(element.name => element.type.to_s)
        end
        tmp.delete_if {|n,x| match_regexp(n, "*_id")}          # filter default attributes that are used as foreign key
        unless options[:except_attributes].empty?
          options[:except_attributes].each do |attribute|
            tmp.delete_if {|n,x| match_regexp(n, attribute.to_s)}
          end
        end 
      else
        raise ArgumentError, "#{error_prefix}: Warning you mustn't specify both 'only_attributes' and 'except_attributes' options, please choose one" unless options[:except_attributes].empty?
        options[:only_attributes].each do |attribute|
          raise ArgumentError, "#{error_prefix}: Unknown attribute '#{attribute}' please check it" unless self.new.respond_to?(attribute.to_s)
          self.columns.each do |element|
            tmp = tmp.merge(element.name => element.type.to_s) if element.name == attribute.to_s
          end
        end
      end
      options[:attributes] = tmp
      options.delete(:except_attributes)
      options.delete(:only_attributes)
      
      options[:displayed_attributes].each_index {|i| options[:displayed_attributes][i] = options[:displayed_attributes][i].to_s} 
      
      # create class var to permit to access to search option from te model
      class_eval do
        cattr_accessor :search_index, :association_list
        self.search_index     = options
        self.association_list = assoc_list
        self.const_set "ERROR_PREFIX", error_prefix                                               # permit to use that constant for errors into other methods of the plugin
      end
      
      options[:relationships].each do |relationship_name|                                         # verify if all relationships implement has_search_index
        model = assoc_list[relationship_name][:class_name].constantize
        raise ArgumentError, "#{error_prefix}: relationship '#{relationship_name}' , require '#{model.to_s}' model to implement has_search_index plugin" unless HasSearchIndex::MODELS.include?(model.to_s)
      end
      
    end
    
    # Method to match a regexp with a simple syntax
    # to macth a data that end with 'x' 
    #  #=> "*x"
    # to match a data that start with 'x'
    #  #=> "x*"
    # to match a data that contain 'x'
    #  #=> "*x*"
    # if there's no * then the regexp wil be the exp passed as argument
    #
    def match_regexp(data, exp)
      string = exp.gsub("*","")
      regexp = "^#{string}$"
      regexp = "^[0-9A-Za-z_]*#{string}$" if exp.first == "*"
      regexp = "^#{string}[0-9A-Za-z_]*$" if exp.last == "*"
      regexp = "^#{string}[0-9A-Za-z_]*#{string}$" if exp.last == "*" and exp.first == "*"
      return !data.match(Regexp.new(regexp)).nil?
    end
    
    # return attribute type according to the database informations
    # so the model must have a table into the database in order to get elements informations
    #
    def get_attribute_type(attribute)
      self.columns.each do |element|
        return element.type if element.name == attribute
      end
    end
    
    # method to identify if an attribute belongs to tha additionals attributes
    # return true if it do and false if not
    #
    def is_additional?(attribute_path)
      attribute_path = attribute_path.downcase
      attribute = attribute_path.split(".").last
        object = self
        if attribute_path.include?(".")
          attribute_path.chomp(".#{attribute}").split(".").each do |a|
            object = object.association_list[a.to_sym][:class_name].constantize
          end
        end
      raise "#{ERROR_PREFIX}: Implementation error '#{object}' model must implement has_search_index plugin in order to use directly or undirectly the plugin" unless object.respond_to?(:search_index)
      
      object.search_index[:additional_attributes].include?(attribute)
    end  
    
    # Methods that permit to test all attributes
    # #1 return true if all are additional attributes (cf "is_additional?(attribute)" method)
    # #2 return true if all are database attributes (cf "is_additional?(attribute)" method)
    #
    def only_additional_attributes?(attributes)
      attributes.each_key do |attribute|
        return false unless self.is_additional?(attribute)
      end
      return true
    end

    def only_database_attributes?(attributes)
      attributes.each_key do |attribute|
        return false unless !self.is_additional?(attribute)
      end
      return true
    end

    # Method that permit to get the include array to use as argument to call +find+ from a model
    #
    # ignore permit to avoid the cycle from the many to many relationships like +Role+ and +User+
    # but it's possible for a model to have a relationship that target to itself like +Service+:
    # ==> a 'service' has many 'children', and a 'chidren' is a 'service'
    # but the method avoid the 'children' to have a 'children' like a 'service' to avoid looping.  
    #
    def get_include_array(ignore=[])
      include_array = Array.new
      self.search_index[:relationships].each do |relationship|
        model = self.association_list[relationship][:class_name]
        unless ignore.include?("#{model.to_s}") 
          ignore_copy = ignore.fusion(["#{self.to_s}"])
          model = model.constantize
          if model.get_include_array(ignore_copy.clone)==[]
            include_array << relationship
          else
            include_array << {relationship => model.get_include_array(ignore_copy.clone)}
          end
        end
      end
      return include_array
    end
    
    # Method that permit to verify the match between object's attribute and the value passed into args according to data type (and action if there is one) 
    #
    # ==== examples:
    #
    # search_match?(employee.first,"first_name","jean")
    # ==> return employee  like -> employee.frist_name=="jean"
    #
    def search_match?(object, attribute, value, search_type)
      attribute = attribute.downcase
      attributes = self.search_index[:additional_attributes]
      data = object.send(attribute).to_s
      return false if data.nil?
      if !value.is_a?(Hash) and !value.is_a?(Array)
        if object.search_index[:additional_attributes][attribute]=="string"  # use regexp for string attributes same that use like into sql queries
          return data.downcase.match(Regexp.new(value.to_s.downcase))       # downcase data and value to make the match method case insensitive
        else
          return data == value.to_s
        end
      end

      value_array = (value.is_a?(Array))? value : [ value ]                  # manage the case when only one attribute
      result = nil
      value_array.each do |val|
        raise ArgumentError, "#{ERROR_PREFIX}: Argument missing into value hash : if you use the value hash instead of value you must type it like {:value => foo :action => bar} " if val[:action].nil?

        if val[:action] == "like"
          tmp_result = data.downcase.match(Regexp.new(val[:value].downcase))        # downcase data and value to make the match method case insensitive
        elsif val[:action] == "not like"
          tmp_result = !data.downcase.match(Regexp.new(val[:value].downcase))       # downcase data and value to make the match method case insensitive
        elsif val[:action] == "!="
          tmp_result = !data.send("==",val[:value].to_s)
        elsif val[:action] == "="
          tmp_result = data.send("==",val[:value].to_s)
        elsif ACTIONS[attributes[attribute].to_sym].include?(val[:action])
          tmp_result = data.send(val[:action],val[:value].to_s)
        else
          raise ArgumentError, "#{ERROR_PREFIX}: Unproper operator '#{val[:action]}' for #{attributes[attribute]} datatype"
        end
        result = tmp_result if result.nil?                                          # init the result value
        result |= tmp_result if search_type=='or'                                    # return the result of multiple values for one attribute
        result &= tmp_result if search_type =='and' or search_type == 'not'
      end
      
      return result
    end

    # Method that permit to get nested resources of an object with an array of these nested resources
    #
    # ==== example:
    #
    # Employee.get_nested_object(Employee.first, ["job_contract","job_contract_type"])
    # ==> Employee.first.job_contract.job_contract_type
    #
    # Customer.get_nested_object(Customer.first,["establishments","contacts","numbers","number_type"])
    # ==> collection of number_type, of all numbers --> of all contacts --> of all establishments --> of the current customer
    # 
    def get_nested_object(object, nested_resources)
      return nil unless nested_resources.is_a?(Array)
      nested_resources.each do |nested_ressource|
        if object.is_a?(Array)
          collection = Array.new
          object.each do |sub_object|
              if sub_object.send(nested_ressource).is_a?(Array)
                collection = collection.fusion(sub_object.send(nested_ressource))
              else
                collection << sub_object.send(nested_ressource)
              end
          end
          object = collection
        else
          object = object.send(nested_ressource)
        end
      end
      return object
    end

    # Method that permit to format the attributes hash when using search with method to perform a general search
    # 'value' -> the searched value 
    # 'include_hash' -> the relationships you want to search in
    # ==> {key => value} : 'key' is the relationship, 'value' is the array of attributes you to test, let it empty to test all attributes 
    # ==== example :
    #
    # Model.search_attributes_format_hash("value")
    # => {"attribute1"=>"value", "attribute2"=>"value",ect...}
    #
    # Model.search_attributes_format_hash("value",{:relationship=>[],:relationship2=>["attribute1","attribute2"]})
    # => {"attribute1"=>"value", "attribute2"=>"value","relationship.attribute1"=>"value",ect...}  (!) test all attributes for relationship
    #
    # Employee.search_attributes_format_hash("value",[:user=>["username"]})
    # => {"last_name"=>"value","first_name"=>"value","users.username"=>"value"}
    #
    def search_attributes_format_hash(value ,include_hash={})
      attributes = Hash.new
      self.search_index[:attributes].merge(self.search_index[:additional_attributes]).each_key do |attribute|
        attributes = attributes.merge({attribute => value})
      end
      return attributes if include_hash.empty?
      raise ArgumentError, "#{ERROR_PREFIX}: relationships :#{include_array.inspect} undefined for has_search_index" if self.search_index[:relationships].nil?
      self.search_index[:relationships].each do |relationship|
        if include_hash.keys.include?(relationship)
          self.association_list[relationship][:class_name].constantize.search_attributes_format_hash(value).each_pair do |sub_attrib,val|
            attributes = attributes.merge("#{relationship}.#{sub_attrib}"=> val) if include_hash[relationship].include?(sub_attrib)
          end
        end
      end
      return attributes
    end


    # Method that permit to search attributes that are or not into database
    # You can access to the :action possible values into ACTIONS constant hash with the data type as key
    # for example ==> ACTIONS[:string] ==> ["not like","like","==","!="]
    # you can precise search type adding this pair of key => value into attributes hash:
    # :search_type => "and"                       ->  Default one , to get result that match with all asserts
    #                  "or"                       ->  To get result that match at least with one of all asserts
    #                  "not"                      ->  To get result that match with no asserts
    # the method is case insensitive
    #
    # ==== example:
    #
    # # General case
    #
    #    # Standard search :
    #
    #     Model.search_with("[sub_model.]attribute" => value | {:value => value, :action => action} [, ...] [,:search_type => "and"])
    #
    #    # Or pass a value at first argument and an array the models wheres to perform the search :
    #
    #     Model.search_with( value ,[Model1,Model2] )
    #
    #    # In some cases you can need to test more than one value for only one attribute :
    #
    #     Model.search_with( attribute =>[ {:value => first_value, :action => first_action}, {:value => second_value, :action => second_action} ])
    #     => it' s like to do ' attribute => {:value => first_value, :action => first_action}, attribute =>{:value => second_value, :action => second_action} '
    #        :but as you know, you can't pass the same key twice into an Hash.
    #
    #    # with an attribute that is not into database
    #     
    #     User.search_with("expired?" => true) or User.search_with("expired?" => {:value => true, :action => "="})
    #     => all users like an_user.expired?==true    (PS : the both are equal because default action is '=' for all data types, and 'like' (cf. sql) for strings )
    #
    #    # with a nested attribute into database or not
    #    (!) you must type the attribute in plural if the resource has many or has and belongs to many, and in singular if the resource has one
    #
    #    #  User Has and belongs to many Role :
    #
    #     User.search_with("roles.name" => "admin")
    #     => all users that one role name is equal to "admin" at least 
    #      
    #    # Employee Has one JobContract :
    #
    #     Employee.search_with("job_contract.start_date" => "2/2/1900")
    #     => nothing because the date is to old, there's no user that have a job_contract's start_date equal to that one
    #
    #    # the same has precedent with some args :
    #
    #     Employee.search_with("job_contract.start_date" =>{:value => "2/2/1900", :action => ">"})
    #     => all employees that job_contract start_date is greater than 2/2/1900
    #
    #    # Customer has many Establishment and Establishment Has one Address :
    #
    #     Customer.search_with("establishments.address.zip_code" => 97438)
    #     => return all customers that have at least one establishment with zip code equal to '97438'
    #
    def search_with(attributes={}, include_array=nil)

      if !attributes.is_a?(Hash)                                                                  # perform a general search onto the argument value
        attribute_value = attributes
        attributes = self.search_attributes_format_hash(attribute_value ,include_array||={})
        search_type = "or"
      else
        search_type = (attributes[:search_type].nil?)? "and" : attributes.delete(:search_type)    # default value for the search type if not precised  
        attributes.each_key do |attribute|
          attribute = attribute.downcase
          model = self
          if attribute.include?(".")
            attribute.chomp(".#{attribute.split(".").last}").split(".").each do |a|
              raise "#{ERROR_PREFIX}: Wrong attribute name '#{attribute}' maybe you misspelled it" if model.association_list[a.to_sym].nil?
              model = model.association_list[a.to_sym][:class_name].constantize
            end
          end

          raise "#{ERROR_PREFIX}: Implementation error '#{model.to_s}' model must implement has_search_index plugin in order to use directly or undirectly the plugin" unless model.respond_to?("search_index")
          
          if !model.search_index[:attributes].include?(attribute.split(".").last) and !model.search_index[:additional_attributes].include?(attribute.split(".").last)
            raise ArgumentError, "#{ERROR_PREFIX}: Attribute '#{attribute.split(".").last}', undefined for has_search_index into #{model.to_s} model"
          end
        end
      end

      database_result = search_database_attributes(attributes, search_type)
      additional_result = search_additional_attributes(attributes, search_type)

      # discard one of the two results array if there's only one type of attributes
      return additional_result if only_additional_attributes?(attributes)                  # return only additional attributes research result
      return database_result if only_database_attributes?(attributes)                      # return only database research result
      
      # regroup the two results array according to search type 
      # PS: for the search type 'not' it's equal to 'and' because we need to keep values that are into the two arrays in the same time
      if search_type == "or"
        return additional_result | database_result                                         # get results that respond to one criterion at least
      else
        return additional_result & database_result                                         # get results that respond to all criteria or no criteria
      end

    end

    # method to get the negative form of the comparators ex =! for =
    def negative(action)
      positive = ["=",">","<","like"]
      negative = ["!=","<=",">=","not like"]
      return negative[positive.index(action)] if positive.include?(action)
      return positive[negative.index(action)] if negative.include?(action)
    end
              
    # method to format the criterion's value
    def format_value(params, data_type)
      case data_type
        when 'date'
          d= params['date(0i)']
          m= params['date(1i)'] 
          y= params['date(2i)']
          return "#{y}/#{m}/#{d}"
        when 'datetime'
          d= params['date(0i)']
          m= params['date(1i)'] 
          y= params['date(2i)']
          h= params['date(3i)']
          min= params['date(4i)']
          return "#{y}/#{m}/#{d} #{h}:#{min}:00"
        when 'boolean'
          return params['value'].to_b                                                            # .strip permit to avoid unused spaces
        when 'float'
          return params['value'].to_f
        when 'integer'
          return params['value'].to_i
        else
          return params['value'] unless params['value'].nil? 
      end
    end

    private
      
      # Method that permit to search for additional attributes
      # look for search_with() public method for examples
      # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
      # # 'search_type' is a string include into that range ["or","and","not"]
      #
      def search_additional_attributes(attributes, search_type)
        collection = self.find(:all)
        search_type=="or" ? additional_result = Array.new : additional_result = collection    # initialization is different according to search type because of using  & or | on arrays

        attributes.each_pair do |attribute,value|
          if is_additional?(attribute)
          tmp_result = Array.new
          collection.each do |object|
            if attribute.include?(".")                                                        # nested resource ex=> roles.name
              nested_resources = attribute.split(".")
              nested_attribute = nested_resources.pop
              nested_object = get_nested_object(object, nested_resources)
              if nested_object.is_a?(Array)                                                   # has many sub resources
                nested_object.each do |sub_obj|
                  tmp_result << object if search_match?(sub_obj, nested_attribute, value, search_type)
                end
              else
                tmp_result << object if search_match?(nested_object, nested_attribute, value, search_type)
              end
            else
              tmp_result << object if search_match?(object, attribute, value, search_type)
            end
          end
          additional_result = additional_result | tmp_result  if search_type=="or"              # get results that respond to one criterion at least
          additional_result = additional_result & tmp_result  if search_type=="and"             # get results that respond to all criteria
          end
        end
        additional_result = collection - additional_result if search_type == "not"              # get results that don't respond to all criteria
        
        return additional_result
      end

      # Method to search into database for attributes
      # look for search_with() public method for examples
      # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
      # # 'search_type' is a string include into that range ["or","and","not"]
      #
      def search_database_attributes(attributes, search_type)
        conditions_array = [""]
        operator = (search_type=='not')? 'and' : search_type                # if search type is 'not', invert all actions and use 'and' search_type
        unless attributes.nil?
          attributes.each_pair do |attr_with_prefix, value|
            attr_with_prefix = attr_with_prefix.downcase
            unless is_additional?(attr_with_prefix)
              if attr_with_prefix.include?(".")                            # check if the attribute come from a nested resource
                attribute = attr_with_prefix.split(".").last
                attribute_path = attr_with_prefix.chomp(".#{attribute}")
                attribute_prefix = generate_attribute_prefix(self, "#{self.table_name}.#{attribute_path}")
                model = self
                attribute_path.split(".").each do |att|
                  model = model.association_list[att.to_sym][:class_name].constantize if model.new.respond_to?(att)
                end
              else
                attribute = attr_with_prefix
                attribute_prefix = self.table_name
                model = self
              end
     
              if model.new.respond_to?(attribute)
                formatted_attribute = "#{attribute_prefix}.#{attribute}"     # prefix attribut with the model that it depend on to avoid ambiguous or for nested resource
                if !value.is_a?(Hash) and !value.is_a?(Array)
                  conditions_array[0] << " #{operator} " unless conditions_array[0]==""
                  conditions_array[0] << "#{formatted_attribute}"
                  if model.search_index[:attributes][attribute]=="string"
                    conditions_array[0] << ( search_type == "not" ? " #{self.negative('like')}?" : " like?")
                    conditions_array << "%#{value}%"
                  else
                    conditions_array[0] << ( search_type == "not" ? " #{self.negative('=')}?" : " =?")
                    conditions_array << value
                  end
                else
                  value_array = (value.is_a?(Array))? value : [ value ]      # manage the case when only one value for the attribute
                  
                  value_array.each do |val|
                    val[:action] = self.negative(val[:action]) if search_type == "not" 
                    conditions_array[0] << " #{operator} " unless conditions_array[0]==""
                    conditions_array[0] << "#{formatted_attribute} #{val[:action]}?"
                    if val[:action] == "like" or val[:action] == "not like"
                      conditions_array << "%#{val[:value]}%"
                    else 
                      conditions_array << val[:value]
                    end
                  end
                end
              else
                raise ArgumentError, "#{ERROR_PREFIX}: Wrong argument #{attr_with_prefix} maybe you misspelled it"
              end
            end 
          end
#           puts "(debug)[has_search_index.rb l.#{__LINE__}] #{self}.find(:all, :include =>#{get_include_array.inspect}, :conditions =>#{conditions_array.inspect})"                    #### use this line when need to debug the search engine to see the find with arguments
          return self.all(:include => get_include_array, :conditions => conditions_array)
        end

        return []
      end
      
      # Method to generate attribute prefix to put into conditions array
      # It is called by "search_database_attributes" method
      # ps : This method manage 3 levels of ambiguity like rails to create join relationships from ':include' hash into 'find'
      #      First it look the name of the last model, before the attribute that prefixed with that model's tablename to avoid ambiguity like:
      #       # =>  #{model_table_name}.attribute
      #      But in some cases there're two model but from two different parent models. When it's the case rails suffix the model table_name like:
      #       # =>  #{model_table_name}_#{parent_model_table_name}.attribute
      #      And in some cases if there's several times the same couple model/parent_model the suffix is indexed like:
      #       # =>  #{model_table_name}_#{parent_model_table_name}_#{i}.attribute
      #       with 'i' start at 2 for the first repetition of the same couple model/parent_model  
      # Attributes:
      #
      #   attribute_prefix => the brut attribute prefix from the search plugin
      #   
      #   parent_model => the model from which is called the search_plugin
      #
      def generate_attribute_prefix(parent_model, attribute_prefix)

        model       = attribute_prefix.split(".")[-2]
        sub_model   = attribute_prefix.split(".")[-1]
        count_table = get_model_order(parent_model.table_name, parent_model.get_include_array, sub_model, model)
        
        #### filter the count_table to get only the models_hierarchy that is not the first and that is like the current models_hierarchy
        filtered_count_table = count_table.reject {|n| !(n.split(".")[-2..-1] == attribute_prefix.split(".")[-2..-1]) or n == count_table.first}
        ################  
        
        model_index = filtered_count_table.index(attribute_prefix)
        
        # OPTIMIZE maybe remove that comment if it's not necessary
        #  manage the pluralize wiht caution because pluralize do not works properly with plural strings that do not finish with one "s"
        #  and when you add a relationship into the include array if there is a redundancy of that relationship the find seems to use 
        #  the pluralize method that add one 's' to already pluralize string like (children that come from employees) become 'childrens_employees'
        #  then to make the find work properly we have to respect the name given to the table joins aliases by the find to be able to acces to the 
        #  data.
        #  But that error concerne only the redundancy management, so if the relationship do not suffer of redundancy there will not have an
        #  error. 
        #  example :
        #   # => Employee.all(:include => [:premia], :conditions => ["premia.id =?",0])                     it will work
        #   # => Service.all(:include => [:children], :conditions => ["childrens_services.id =?",0])
        #        children is a service belonging to another service that's why there is a redundancy but the fact is that we need to add one 's'
        #        to 'chidren' to make it work properly.
        
        ######### manage the self include cf(if a model include a relationship that refer to himself)
        return "#{sub_model.pluralize}_#{model.pluralize}" if retrieve_relationship_class(attribute_prefix, model) == retrieve_relationship_class(attribute_prefix, sub_model)
        #########
        
        model = model.pluralize unless sub_model.plural?
        sub_model = sub_model.pluralize unless sub_model.plural?
        return "#{sub_model}" if count_table.first == attribute_prefix #models_hierarchy
        case model_index
          when nil
            raise "#{ERROR_PREFIX}: AttributPrefixError: #{attribute_prefix} do not match with the plugin definition into the model"
          when 0
            return "#{sub_model.pluralize}_#{model.pluralize}"
          else
            return "#{sub_model.pluralize}_#{model.pluralize}_#{model_index+1}"
        end
      end
      
      # method called by "generate_attribute_prefix" to parse recursively the include_array
      #
      def get_model_order(parent_model, include_array, sub_model, model, path="")
        path += "#{parent_model}."
        count_table = []
        include_array.each do |e|
          if e.is_a?(Hash)
            current = e.keys[0].to_s
            count_table = count_table + get_model_order(current, e.values[0], sub_model, model, path)
          else
            current = e.to_s
          end
          count_table << path + current if sub_model == current
        end
        return count_table
      end
      
      # method to respect the DRY and to externalise the model retrievement from a relationship
      # according to a path ex :
      # # => retrieve_relationship_class("Employee.numbers", "numbers") -> Number
      #
      def retrieve_relationship_class(path, relationship)
        model = self
        return self.to_s if relationship == self.table_name
        path.gsub("#{self.table_name}.","").split(".").each do |e|
            return model.association_list[e.to_sym][:class_name] if e == relationship
            model = model.association_list[e.to_sym][:class_name].constantize
        end
      end
  end

end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasSearchIndex)
end
