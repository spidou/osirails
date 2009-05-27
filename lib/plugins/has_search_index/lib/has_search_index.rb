    module HasSearchIndex
    MODELS = []
    ACTIONS_TEXT = { "=" => "is ",
                    "!=" => "is not ",
                    "like" => "is like",
                    "not like" => "is not like",
                    ">=" => "is greater to equal than",
                    "<=" => "is smaller to equal than",
                    ">" => "is smaller than",
                    "<" => "is greater than"}
    
      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end      
      end

      module ClassMethods

        AUTHORIZED_OPTIONS = [:except_attributes, :only_attributes, :additional_attributes, :only_sub_models, :except_sub_models, :displayed_attributes]
        ACTIONS = { :string   => string = ["not like","like","=","!="],
                    :text     => string,
                    :integer  => integer = [">=","<=","<",">","=","!="],
                    :date     => integer,
                    :datetime => integer,
                    :float    => integer,
                    :boolean  => ["=","!="] }
        
        # method called into all models that implement the plugin 
        # it define search_index class variable based on passed options hash
        #
        def has_search_index( options={} )
          HasSearchIndex::MODELS << self.to_s unless HasSearchIndex::MODELS.include?(self.to_s)
          # affect if nil to avoid testing nullity and emptyness
          options[:additional_attributes] ||={}
          options[:only_attributes]       ||=[]
          options[:except_attributes]     ||=[]
          options[:except_sub_models]     ||=[]
          options[:only_sub_models]       ||=[]
          options[:displayed_attributes]  ||=[]
          
          # check options arg for some errors
#          raise ArgumentError, "(Has_search_index) model: #{self.to_s} : Argument missing you must specify attributes like :attributes => [\"attr1\",\"attr2\",etc...]" if options[:attributes].empty?
          options.keys.each do |key|
            raise ArgumentError, "(Has_search_index) model: #{self.to_s} : Unknown option :#{key.to_s}" unless AUTHORIZED_OPTIONS.include?(key)      
          end
          
          # create a hash to store all associations that concerned the current model
          assoc_list = Hash.new           
          self.reflect_on_all_associations.each do |assoc|
            assoc_list = assoc_list.merge({assoc.class_name =>{:name => assoc.name,:macro => assoc.macro.to_s}}) if assoc.options[:polymorphic].nil? or assoc.options[:polymorphic]==false
          end

          # generate default sub_model array if not present into 'options' argument
          # if except_sub_models is not empty it will discard models from the default sub_models array
          if options[:only_sub_models].empty?
            Logger.new(STDOUT).info("(Warning) sub models aren\'t defined for #{self.to_s} model") if assoc_list.empty?
            options[:sub_models] = Array.new
            assoc_list.each_key do |sb|
              options[:sub_models] << sb if sb.constantize.respond_to?("search_index")                # filter models implementing the plugin 'has_search_index'
            end
            if !options[:except_sub_models].empty?                                                    # filter it if except_sub_model is'nt empty'
              options[:except_sub_models].each do |e|
                options[:sub_models].delete(e)
              end
            end
          else
            raise ArgumentError, "(Has_search_index) model: #{self.to_s} : Warning you mustn't specify both 'only_sub_models' and 'except_sub_models' options, please choose one" unless options[:except_sub_models].empty?
            options[:sub_models] = options[:only_sub_models]
          end
          options.delete(:except_sub_models)
          options.delete(:only_sub_models)
          
          # permit to replace attribute name by an object containing sql informations such as name, type, etc...
          tmp = Hash.new
          if options[:only_attributes].empty?
            self.columns.each do |elmnt|
              tmp = tmp.merge(elmnt.name => elmnt.type.to_s)
            end  
            unless options[:except_attributes].empty?
              options[:except_attributes].each do |e_a|
                tmp.delete(e_a)
              end
            end 
          else
            raise ArgumentError, "(Has_search_index) model: #{self.to_s} : Warning you mustn't specify both 'only_attributes' and 'except_attributes' options, please choose one" unless options[:except_attributes].empty?
            options[:only_attributes].each do |attribute|
              raise ArgumentError, "(Has_search_index) model: #{self.to_s} : Unknown attribute '#{attribute}' please check it" unless self.new.respond_to?(attribute)
              self.columns.each do |elmnt|
                tmp = tmp.merge(elmnt.name => elmnt.type.to_s) if elmnt.name == attribute
              end
            end
          end
          options[:attributes] = tmp
          options.delete(:except_attributes)
          options.delete(:only_attributes)
          
          # create class var to permit to access to search option from te model
          class_eval do
            cattr_accessor :search_index, :association_list
            self.search_index = options
            self.association_list = assoc_list
          end

        end
        
        # return attribute type according to the database informations
        # so the model must have a table into the database in order to get elements informations
        #
        def get_attribute_type(attribute)
          self.columns.each do |elmnt|
            return elmnt.type if elmnt.name==attribute
          end     
        end
        
        # method to identify if an attribute belongs to tha additionals attributes
        # return true if it do and false if not
        #
        def is_additional?(attribute)
          if attribute.include?(".")
            tmp = attribute.split(".")[-2]
            if tmp.plural?
              object = tmp.singularize.camelize.constantize
            else
              object = tmp.camelize.constantize
            end
            attribute = attribute.split(".").last            
          else
            object = self
          end
          raise "(Has_search_index) model:#{self.to_s} : Implementation error #{object} model must implement has_search_index plugin in order to use directly or undirectly the plugin" unless object.respond_to?("search_index")
          return false if object.search_index[:additional_attributes].nil?
          
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

        # method that permit to get the include array recursively(according to sub models)
        # arguments --> ignore=[] (!) You must not use it, it's just for recursive call of the method
        # It permit to skip a model for example for recursive call when an user has and belongs to many roles 
        # If we try to get user include array we'll need also to get role's one,
        # because role is a sub resource of user but if we do we'll find user that have role as sub resource to so 
        # we'll loop indefinetly that's why if user have a sub_model role, that mean we need to call recursively Role.get_include_array(ignore << self) self = User
        # why an array ? to permit more than one recursive call
        # why self ? to avoid looping (we never go back to a checked model)
        #
        def get_include_array(ignore=[])
          include_array = Array.new
          self.search_index[:sub_models].each do |model|
            model = model.constantize
            unless ignore.include?(model) # avoid stack level to deep for has and belongs too many relationships ex: user <-roles  ,  role<-users
              attribute = self.new.respond_to?(model.to_s.tableize) ? model.to_s.tableize : model.to_s.tableize.singularize
              if model.search_index[:sub_models].nil? or model.get_include_array(ignore << self )==[]
                include_array << attribute.to_sym        
              else
                include_array << {attribute.to_sym => model.get_include_array(ignore << self )}  
              end  
            end            
          end
          return include_array
        end
        
        # Method that permit to verify the match between object's attribute and the value passed into args acording to data type (and action if there is one) 
        #
        # ==== exmaple:
        #
        # search_match?(employee.first,"first_name","jean")
        # ==> return employee  like -> employee.frist_name=="jean"
        #
        def search_match?(object, attribute, value, search_type)
          attributes = self.search_index[:additional_attributes]
          data = object.send(attribute).to_s
          return false if data.nil?
          if !value.is_a?(Hash) and !value.is_a?(Array)
            if object.search_index[:additional_attributes][attribute]=="string"          #  use regexp for string attributes same that use like into sql queries
              return data.downcase.match(Regexp.new(value.to_s.downcase))               #  downcase data and value to make the match method case insensitive
            else
              return data == value.to_s
            end
          end       

          value_array = (value.is_a?(Array))? value : [ value ]                           # manage the case when only one attribute
          result = nil
          value_array.each do |val|
            raise ArgumentError, "(Has_search_index): Argument missing into value hash : if you use the value hash instead of value you must type it like {:value => foo :action => bar} " if val[:action].nil?
          
            if val[:action] == "like"
              res = data.downcase.match(Regexp.new(val[:value].downcase))              #  downcase data and value to make the match method case insensitive
            elsif val[:action] == "not like"
              res = !data.downcase.match(Regexp.new(val[:value].downcase))             #  downcase data and value to make the match method case insensitive
            elsif val[:action] == "!="
              res = !data.send("==",val[:value].to_s)
            elsif val[:action] == "="
              res = data.send("==",val[:value].to_s)
            elsif ACTIONS[attributes[attribute].to_sym].include?(val[:action])
              res = data.send(val[:action],val[:value].to_s)
            else
              raise ArgumentError, "(Has_search_index): Unproper operator '#{val[:action]}' for #{attributes[attribute]} datatype"
            end
            result = res if result.nil?                                                # init the result value
            result |= res if search_type=='or'                                          # make boolean test to return the result of a multiple value for one attribute
            result &= res if search_type =='and' or search_type == 'not'
            
          end
          
          return result
        end

        # Method that permit to get nested resources of an object with an array of these nested resources
        #
        #==== example:
        #
        # Employee.get_nested_object(Employee.first, ["job_contract","job_contract_type"])
        # ==> Employee.first.job_contract.job_contrct_type
        #
        # Customer.get_nested_object(Customer.first,["establishments","contacts","numbers","number_type"])
        # ==> collection of number_type, of all numbers --> of all contacts --> of all establishment --> of the current customer
        # 
        def get_nested_object(object, nested_resources)
          return nil unless nested_resources.is_a?(Array)
          nested_resources.each do |nested_ressource|
            if object.is_a?(Array)
              collection = Array.new
              object.each do |sub_obj|
                  if sub_obj.send(nested_ressource).is_a?(Array)
                    collection = collection.fusion(sub_obj.send(nested_ressource))
                  else
                    collection << sub_obj.send(nested_ressource)
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
        # 'include_array' -> the sub_models you want to search in
        # ==== example :
        #
        # Model.search_attributes_format_hash("value")
        # => {"attribute1"=>"value", "attribute2"=>"value",ect...}
        #
        # Model.search_attributes_format_hash("value",["SubModel1","SubModel2"])
        # => {"attribute1"=>"value", "attribute2"=>"value","sub_model1.attribute1"=>"value",ect...}
        #
        # Employee.search_attributes_format_hash("value",["User"])
        # => {"last_name"=>"value","users.username"=>"value"}
        #
        # FIXME Maybe You can use an hash for include array to manage a deep hierarchy of sub_models
        def search_attributes_format_hash(value ,include_array=[])
          attributes = Hash.new
          self.search_index[:attributes].merge(self.search_index[:additional_attributes]).each_key do |attribute|
            attributes = attributes.merge({attribute => value})
          end
          return attributes if include_array.empty?
          raise ArgumentError, "(Has_search_index): Undefined sub models :#{include_array.inspect} for #{self.to_s} model" if self.search_index[:sub_models].nil?
          self.search_index[:sub_models].each do |sub_model|
            if include_array.include?(sub_model)
              sub_model.constantize.search_attributes_format_hash(value).each_pair do |sub_attrib,val|
                attributes = attributes.merge("#{self.association_list[sub_model][:name]}.#{sub_attrib}"=> val)
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
        #==== example:
        #
        ## General case
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
        
        #     Model.search_with( attribute =>[ {:value => first_value, :action => first_action}, {:value => second_value, :action => second_action} ])
        #     => it' s like to do ' attribute => {:value => first_value, :action => first_action}, attribute =>{:value => second_value, :action => second_action} '
        #        :but as you know, you can't pass the same key twice into an Hash.
        #
        ## with an attribute that is not into database
        #     
        #     User.search_with("expired?" => true) or User.search_with("expired?" => {:value => true, :action => "="})
        #     => all users like an_user.expired?==true    (PS : the both are equal because default action is '=' for all data types, and 'like' (cf. sql) for strings )
        #
        ## with a nested attribute into database or not
        #(!) you must type the attribute in plural if the resource has many or has and belongs to many, and in singular if the resource has one
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
   
          if !attributes.is_a?(Hash)                                                      # perform a general search onto the ragument value
            attribute_value = attributes
            attributes = self.search_attributes_format_hash(attribute_value ,include_array||=[])
            search_type = "or"
          else
            search_type = (attributes[:search_type].nil?)? "and" : attributes.delete(:search_type)    # default value for the search type if not precised  
            attributes.each_key do |att|

              # att.split(".").last  --> represent the last part of the attribute tree
              # if there's not '.' it  will return the attribute but if there is one or more it mean that there's nested resources that's why
              # whe need to get the last for the attribute( att.split(".").last ) and 
              # the one before the last for the model the attribut depend on ( att.split(".")[-2] ) to

              if !att.include?(".")                                                       # there's not nested resource the model is self
                model = self
              elsif att.split(".")[-2].camelize.plural?                                    # there's many nested resource the model is the nested resource
                model = att.split(".")[-2].camelize.singularize.constantize
              else                                                                         # there's one nested resource te model is the nested resource
                model = att.split(".")[-2].camelize.constantize
              end
              if !model.search_index[:attributes].include?(att.split(".").last) and !model.search_index[:additional_attributes].include?(att.split(".").last)             
                raise ArgumentError, "(Has_search_index): You can't search for attribute '#{att.split(".").last}', because it's not indexed into #{model.to_s} model"
              end 
            end
          end

          database_result = search_database_attributes(attributes, search_type)
          additional_result = search_additional_attributes(attributes, search_type)

          # discard one of the two results array if there's only one type of attributes
          return additional_result if only_additional_attributes?(attributes)                        # return only additional attributes research result 
          return database_result if only_database_attributes?(attributes)                            # return only database research result
          
          # regroup the two results array according to search type 
          # PS: for the search type 'not' it's equal to 'and' because we need to keep values that are into the two arrays in the same time
          if search_type=="or"
            return additional_result | database_result                                               # get results that respond to one criterion at least
          else
            return additional_result & database_result                                               # get results that respond to all criteria or no criteria
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
        def format_value(params)
          case params['attribute'].split(",")[0]
            when 'date'
              m= params['date(3i)'] 
              d= params['date(2i)'] 
              y= params['date(0i)'] 
              return "#{y}/#{m}/#{d}"
            when 'datetime'
              min= params['date(5i)']
              h= params['date(4i)']
              m= params['date(3i)'] 
              d= params['date(2i)'] 
              y= params['date(0i)'] 
              return "#{y}/#{m}/#{d}"
            when 'boolean'
              return params['value'].to_b                        # .strip permit to avoid unused spaces
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
            search_type=="or" ? additional_result = Array.new : additional_result = collection        # initialization is different according to search type because of using  & or | on arrays

            attributes.each_pair do |attribute,value|
              if is_additional?(attribute)
              tmp_result = Array.new             
              collection.each do |object|                                                                
                  if attribute.include?(".")                                                         # nested resource ex=> roles.name                        
                    nested_resources = attribute.split(".")                 
                    nested_attribute = nested_resources.pop
                    nested_object = get_nested_object(object, nested_resources)
                    if nested_object.is_a?(Array)                                                    # has many sub resources
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
              additional_result = additional_result | tmp_result  if search_type=="or"               # get results that respond to one criterion at least
              additional_result = additional_result & tmp_result  if search_type=="and"              # get results that respond to all criteria
              end
            end
            additional_result = collection - additional_result if search_type == "not"               # get results that don't respond to all criteria

            return additional_result
          end

          # Method to search into database for attributes
          # look for search_with() public method for examples
          # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
          # # 'search_type' is a string include into that range ["or","and","not"]
          #
          def search_database_attributes(attributes, search_type)
            conditions_array = [""]
            operator = (search_type=='not')? 'and' : search_type                                              # if search type is 'not', invert all actions and use 'and' search_type
            unless attributes.nil?
              attributes.each_pair do |attribute,value|
                unless is_additional?(attribute)
                  if attribute.include?(".")
                    nested_resource = attribute.split(".")[-2]                                                # '-2' point to the second element from the end of the array
                    if nested_resource.plural?
                      model = nested_resource.singularize.camelize.constantize
                    else
                      model = nested_resource.camelize.constantize
                    end
                    good_attribute = model.new.respond_to?(attribute.split(".").last)
                  else
                    model = self
                    good_attribute = self.new.respond_to?(attribute)
                  end
                  if good_attribute
                    formatted_attribute = "#{model.table_name}.#{attribute.split(".").last}"                  # prefix attribut with the model that it depend on to avoid ambiguous or for nested resource
                    
                    if !value.is_a?(Hash) and !value.is_a?(Array)
                      conditions_array[0] << " #{operator} " unless conditions_array[0]==""
                      conditions_array[0] << "#{formatted_attribute}"
                      if model.search_index[:attributes][attribute.split(".").last]=="string"
                        conditions_array[0] << " like?"
                        conditions_array << "%#{value}%"
                      else
                        conditions_array[0] << " =?"
                        conditions_array << value
                      end
                    else
                      value_array = (value.is_a?(Array))? value : [ value ]                                 # manage the case when only one attribute
                      
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
                    raise ArgumentError,  "(Has_search_index): Wrong argument #{a} maybe you misspelled it"
                  end
                end 
              end
#raise conditions_array.inspect+" "+attributes.inspect
              return   self.find(:all, :include => get_include_array, :conditions => conditions_array)
            end
            return nil
          end
          
      end

    end

    # Set it all up.
    if Object.const_defined?("ActiveRecord")
      ActiveRecord::Base.send(:include, HasSearchIndex)
    end
