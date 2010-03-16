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
    include ActiveRecord::ConnectionAdapters::DatabaseStatements                          # Used by method 'check_relationships_options'
  
    AUTHORIZED_OPTIONS = [ :except_attributes,
                           :only_attributes,
                           :additional_attributes,
                           :only_relationships,
                           :except_relationships,
                           :displayed_attributes,
                           :main_model ]

    ACTIONS = { :string   => string = [ "like", "not like", "=", "!=" ],
                :text     => string,
                :binary   => string,
                :integer  => integer = [ ">=", "<=", ">", "<", "=", "!=" ],
                :date     => integer,
                :datetime => integer,
                :decimal  => integer,
                :float    => integer,
                :boolean  => [ "=", "!=" ] }
    
    # method called into all models that implement the plugin 
    # it define search_index class variable based on passed options hash
    def has_search_index( options = {} )
      
      error_prefix = "(has_search_index) model: #{self} >"
      const_set 'ERROR_PREFIX', error_prefix unless const_defined?('ERROR_PREFIX')
      
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
        raise ArgumentError, "#{error_prefix} Unknown option :#{key.to_s}" unless AUTHORIZED_OPTIONS.include?(key)      
      end
      
      # create a hash to store all associations that concerned the current model
      assoc_list = Hash.new
      self.reflect_on_all_associations.each do |assoc|
        assoc_list.merge!(assoc.name => assoc) if [nil, false].include?(assoc.options[:polymorphic])
      end
      
      # check & prepare relationshsips
      options[:relationships] = check_relationships(assoc_list, options, error_prefix)
      options.delete(:except_relationships)
      options.delete(:only_relationships)
      
      # check & prepare attributes
      options[:attributes] = check_attributes(options, error_prefix)
      options.delete(:except_attributes)
      options.delete(:only_attributes)
      
      # prepare disaplayed_attributes
      message  = "#{error_prefix} :displayed_attributes is wrong. "
      message += "Expected Array but was '#{options[:displayed_attributes].inspect}':#{options[:displayed_attributes].class.to_s}"
      raise ArgumentError, message unless options[:displayed_attributes].is_a?(Array)
      options[:displayed_attributes].collect!(&:to_s)
      
      # prepare additional_attributes
      message  = "#{error_prefix} :additional_attributes is wrong: "
      message += "Expected Hash but was '#{options[:additional_attributes].inspect}':#{options[:additional_attributes].class.to_s}"
      raise ArgumentError, message unless options[:additional_attributes].is_a?(Hash)
      options[:additional_attributes].dup.each_pair do |attribute, type|
        options[:additional_attributes].merge!(attribute.to_s => type.to_s)
        options[:additional_attributes].delete(attribute)
      end
      
      check_relationships_options(options[:relationships])
      
      # create class var to permit to access to search option from te model
      class_eval do
        cattr_accessor :search_index, :association_list
        self.search_index = {}.merge(options)                                            # get all attributes and relationships configured into the plugin
        self.association_list = assoc_list                                               # get all associations configured into the plugin
      end
      
      options[:relationships].each do |relationship_name|                                # verify if all relationships implement has_search_index
        model   = self.reflect_on_association(relationship_name).class_name     
        message = "#{error_prefix} relationship '#{relationship_name}' needs the '#{model}' model to implement has_search_index plugin"
        raise ArgumentError, message unless HasSearchIndex::MODELS.include?(model)
      end
      
    end
    
    # Method to match a simple regexp with a data string
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
      regexp = "^[0-9A-Za-z_]*#{string}[0-9A-Za-z_]*$" if exp.last == "*" and exp.first == "*"
      return !data.match(Regexp.new(regexp)).nil?
    end
    
    # Method to return all attributes including additionals
    #
    def search_index_attributes
      self.search_index[:attributes].merge(self.search_index[:additional_attributes])
    end
    
    # return attribute type according to plugin definition
    #
    def search_index_attribute_type(attribute)
      self.search_index_attributes[attribute]
    end
    
    # method to identify if an attribute belongs to the additionals attributes
    # return true if it do and false if not
    #
    def is_additional?(attribute_path)
      attribute_path = attribute_path.downcase
      attribute      = attribute_path.split(".").last
      object         = self
      if attribute_path.include?(".")
        attribute_path.chomp(".#{attribute}").split(".").each do |a|
          message = "#{self::ERROR_PREFIX} Association '#{a}' undefined for '#{object.to_s}' model"
          raise ArgumentError, message if object.association_list[a.to_sym].nil?
          object = object.association_list[a.to_sym].class_name.constantize
        end
      end
      message  = "#{self::ERROR_PREFIX} Implementation error '#{object}' model must implement has_search_index"
      message += " plugin in order to use directly or undirectly the plugin"
      raise message unless object.respond_to?(:search_index)
      
      object.search_index[:additional_attributes].include?(attribute)
    end  
    
    # Methods that permit to know ther's only one type of attributes
    # #1 return true if all are additional attributes (cf "is_additional?(attribute)" method)
    # #2 return true if all are database attributes (cf "is_additional?(attribute)" method)
    #
    def only_additional_attributes?(attributes)
      attributes.each_key {|attribute| return false unless self.is_additional?(attribute)}
      true
    end

    def only_database_attributes?(attributes)
      attributes.each_key {|attribute| return false if self.is_additional?(attribute)}
      true
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
        model = self.association_list[relationship].class_name
        unless ignore.include?("#{model.to_s}") 
          ignore_copy = ignore.fusion(["#{self.to_s}"])
          model       = model.constantize
          model_include_array = model.get_include_array(ignore_copy.clone)
          if model_include_array == []
            include_array << relationship
          else
            include_array << {relationship => model_include_array}
          end
        end
      end
      return include_array
    end
    
    # Method that filter a given include_array according to attribute's prefixes given in arguments
    #
    def filter_include_array_from_prefixes(include_array, prefixes, level = 0)
      return [] if prefixes.empty? or prefixes.nil?
      relationships_by_level = []
      result                 = []
      prefixes.each do |prefix|
        prefix.split('.').each_with_index do |relationship, i|
          relationships_by_level[i] ||= [] 
          relationships_by_level[i] << relationship.downcase
        end
      end
      include_array.each do |element|
        symbol = element.is_a?(Hash) ? element.keys.first : element       
        unless relationships_by_level[level].nil? or !relationships_by_level[level].include?(symbol.to_s.downcase)
          if element.is_a?(Hash)
            nested  = filter_include_array_from_prefixes(element[symbol], prefixes, level + 1)     
            result << (nested.empty? ? symbol : {symbol => nested})
          else
            result << symbol
          end
        end
      end
      result
    end
    
    # Method that permit to verify the match between object's attribute and the value passed into args according to data type (and action if there is one) 
    #
    # ==== examples:
    #
    # search_match?(Employee.first,"first_name","jean", "or")
    # ==> return +True+ if (employee.frist_name=="jean") and +False+ if not
    #
    # search_match?(User.first, "expired?", "true false 1", "or")
    # ==> return +True+ if expired? is in('true', 'false', '1')
    #
    # The same as below works if +values+ is a hash like {:value => "value other_value etc...", :action => "action"}
    # 
    # +values+ can also be an array of hash like [{:value => 1, ...}, {:value => 2, ...}]
    #
    def search_match?(object, attribute, values, search_type)
      raise ArgumentError, "search_type should be in ('or', 'and', 'not')" unless ['or', 'and', 'not'].include?(search_type)
      attribute  = attribute.downcase
      attributes = self.search_index[:additional_attributes]
      data       = object.send(attribute).to_s.downcase                                  # downcase data to make the match method case insensitive
      tmp_result = result = nil

      return false if data.nil?
      if !values.is_a?(Hash) and !values.is_a?(Array)
        splited_values = split_value(object.class, attribute, values)                    # permit to manage when passsing multiple values in the same field

        splited_values.each do |value|
          value        = value.to_s.downcase                                             # downcase value to make the match method case insensitive
          is_string    = ["string", "text"].include?(object.search_index[:attributes][attribute])
          tmp_result ||= is_string ? data.match(Regexp.new(value)) : data == value
        end
        return (search_type == 'not')? !tmp_result : tmp_result
      end

      value_array = (values.is_a?(Array))? values : [ values ]                           # manage the case when only one attribute
          
      
      value_array.each do |val|
        message  = "#{self::ERROR_PREFIX} Argument missing into value hash :"
        message += " if you use the value hash instead of value you must type it like {:value => foo :action => bar} "
        raise ArgumentError, message if val[:action].nil?
        
        splited_values = split_value(object.class, attribute, val[:value])               # permit to manage when passsing multiple values in the same field 
        tmp_result     = nil
        
        splited_values.each do |value|
          is_like  = !data.match(Regexp.new(value.to_s.downcase)).nil?                   # downcase value to make the match method case insensitive
          is_equal = data.send("==", value.to_s.downcase)

          if ['not like', '!='].include?(val[:action])
            tmp_result = true                                                            # initialise tmp_result to true because of using '&&='
            tmp_result &&= (val[:action] == '!=')? !is_equal : !is_like
          
          elsif ['like', '='].include?(val[:action])
            tmp_result ||= (val[:action] == '=')? is_equal : is_like
             
          elsif ACTIONS[attributes[attribute].to_sym].include?(val[:action])
            tmp_result ||= data.send(val[:action], value.to_s.downcase)
            
          else
            raise ArgumentError, "#{self::ERROR_PREFIX} Unproper operator '#{val[:action]}' for #{attributes[attribute]} datatype"
          end
          tmp_result = !tmp_result if search_type == 'not'
        end
        
        result  = tmp_result if result.nil?                                              # init the result value
        result |= tmp_result if search_type == 'or'                                      # return the result of multiple values for one attribute
        result &= tmp_result if ['and', 'not'].include?(search_type)
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
      raise ArgumentError, "Expected Array but was '#{nested_resources}':#{nested_resources.class.to_s}" unless nested_resources.is_a?(Array)
      nested_resources.collect(&:downcase).each do |nested_ressource|
        if object.is_a?(Array)
          collection = Array.new
          object.each do |sub_object|
              if sub_object.send(nested_ressource).is_a?(Array)
                collection = collection.fusion(sub_object.send(nested_ressource))
              else
                collection << sub_object.send(nested_ressource)
              end
          end
          object = collection.uniq
        else
          object = object.send(nested_ressource)
        end
      end
      return object
    end

    # Method that permit to format the attributes hash when using 'search_with' method to perform a general search
    # 'value' -> the searched value 
    # 'include_hash' -> the relationships you want to search in
    # ==> {key => value} : 'key' is the relationship, 'value' is the array of attributes you to test, let it empty to test all attributes 
    # ==== example :
    #
    # Model.search_attributes_format_hash("value")
    # => {"attribute1"=>"value", "attribute2"=>"value",ect...}
    #
    def format_attributes_hash_for_simple_search(value)
      attributes = Hash.new
      self.search_index_attributes.each_key {|attribute| attributes.merge!({attribute => value}) }
      attributes
    end


    # Method that permit to search attributes that are or not into database
    # You can access to the :action possible values into ACTIONS constant hash with the data type as key
    # for example ==> ACTIONS[:string] ==> ["not like","like","==","!="]
    # the method is case insensitive
    #
    # ==== Simple search :
    #
    #    # You can also pass a value to test all attributes defined for Model:
    #
    #    -> Model.search_with( value )
    #
    # ==== Standard search :
    #
    #    -> Model.search_with( ATTRIBUTE => VALUE, ..., SEARCH_TYPE )
    #
    #    ATTRIBUTE:String
    #    #-> 'attribute'
    #    #-> 'relationship.attribute'
    #  
    #    VALUE:String|Hash|Array
    #    #-> 'value'
    #    #-> {:value => value, :action => action}
    #    #-> [{:value => value, :action => action}, {...}, ...]
    #
    #    SEARCH_TYPE is optional, if not specified default is used 
    #    #-> :search_type => "and"                       ->  Default one , to get result that match with all asserts
    #                        "or"                        ->  To get result that match at least with one of all asserts
    #                        "not"                       ->  To get result that match with no asserts
    #
    #
    #    # In some cases you can need to test more than one value for only one attribute :
    #
    #     Model.search_with( attribute =>[ {:value => first_value, :action => first_action}, {:value => second_value, :action => second_action} ])
    #     => it's like to do 'attribute => {:value => first_value, :action => first_action}, attribute =>{:value => second_value, :action => second_action}'
    #        :but as you know, you can't pass the same key twice into an Hash.
    #
    #    # with an attribute that is not into database
    #     
    #     User.search_with("expired?" => true) or User.search_with("expired?" => {:value => true, :action => "="})
    #     => all users like an_user.expired?==true    (PS : the both are equal because default action is '=' for all data types, and 'like' (cf. sql) for strings )
    #
    #    # with a nested attribute into database or not
    #    (!) you must type the relationship name to get a nested resource
    #
    #    #  User has_and_belongs_to_many :roles :
    #
    #     User.search_with("roles.name" => "admin")
    #     => all users that have at least one +role+ with +name+ equal to "admin"
    #      
    #    # Employee has_one :job_contract :
    #
    #     Employee.search_with("job_contract.start_date" => "2/2/1900")
    #     => nothing because the date is to old, there's no user that have a job_contract's start_date equal to that one
    #
    #    # another example with 'not' +search_type+ to see that it invert +actions+ into +values+:
    #
    #     Employee.search_with("job_contract.start_date" =>{:value => "2/2/1900", :action => ">"}, :search_type => 'not')
    #     => discard all employees with job_contract start_date greater than 2/2/1900
    #
    #    # Customer has_many :establishments, and Establishment has_one :address :
    #
    #     Customer.search_with("establishments.address.zip_code" => 97438)
    #     => return all customers that have at least one establishment with zip code equal to '97438'
    #
    def search_with(args={})

      if !args.is_a?(Hash)                                                                  # perform a general search onto the argument value
        attributes  = self.format_attributes_hash_for_simple_search(args)
        search_type = "or"
      else
        attributes = args
        search_type = (attributes[:search_type].nil?)? "and" : attributes.delete(:search_type).to_s.downcase    # default value for the search type if not present
        attributes.each_key do |attribute_with_prefix|
          attribute_with_prefix = attribute_with_prefix.downcase
          attribute             = attribute_with_prefix.split(".").last
          model                 = self
          
          # check relationship and get the model where to verify the attribute
          if attribute_with_prefix.include?(".")                                                              
            prefix = attribute_with_prefix.chomp(".#{attribute}")
            prefix.split(".").each do |a|
              message = "#{self::ERROR_PREFIX} Relationship '#{a}' into '#{prefix}', undefined for has_search_index into '#{model.to_s}' model"
              raise ArgumentError, message unless model.search_index[:relationships].include?(a.to_sym)
                
              model = model.reflect_on_association(a.to_sym).class_name.constantize
            end
          end
          
          # check the attribute
          message = "#{self::ERROR_PREFIX} Attribute '#{attribute}', undefined for has_search_index into '#{model.to_s}' model"
          raise ArgumentError, message unless model.search_index_attributes.include?(attribute)
        end
      end

      database_result   = search_database_attributes(attributes, search_type) unless only_additional_attributes?(attributes)
      additional_result = search_additional_attributes(attributes, search_type) unless only_database_attributes?(attributes)

      # discard one of the two results array if there's only one type of attributes
      return additional_result if only_additional_attributes?(attributes)                # return only additional attributes research result
      return database_result if only_database_attributes?(attributes)                    # return only database research result
      
      # regroup the two results array according to search type
      # PS: for the search type 'not' it's equal to 'and' because 
      #     we need to keep values that are into the two arrays in the same time,
      #     but all action are inverted (ex: '=' become '!=' if :not is choosen)
      if search_type == "or"
        return additional_result | database_result                                       # get results that respond to one criterion at least
      else
        return additional_result & database_result                                       # get results that respond to all criteria or no criteria
      end
    end

    # method to get the negative form of the comparators ex != for =
    def negative(action)
      positive = ["=",">","<","like"]
      negative = ["!=","<=",">=","not like"]
      return negative[positive.index(action)] if positive.include?(action)
      return positive[negative.index(action)] if negative.include?(action)
    end
              
    # method to format the criterion's DATE value into params
    def format_date(params, data_type)
      case data_type
        when 'date'
          d = params['date(0i)']
          m = params['date(1i)']
          y = params['date(2i)']
          return "#{y}/#{m}/#{d}"
        when 'datetime'
          d = params['date(0i)']
          m = params['date(1i)']
          y = params['date(2i)']
          h = params['date(3i)']
          min= params['date(4i)']
          return "#{y}/#{m}/#{d} #{h}:#{min}:00"
        else
          return params['value'].strip unless params['value'].nil?
      end
    end

    private
      
      ############## private methods called by +has_search_index+ method ################
      
      # Method called by +has_search_index+ to check relationships configuration
      # return an Array of checked relationships from +associations+ and +options+ collection passed as arguments
      # return an empty Array if +except_relationships+ option contains :all symbol
      #
      def check_relationships(associations, options, error_prefix)
        return [] if options[:except_relationships] == :all
        
        options[:relationships] = []
        
        if options[:only_relationships].empty?
          logger.warn("#{error_prefix} No relationships defined") if associations.empty?
          
          message = "#{error_prefix} Warning you must type an array or the symbol :all for :except_relationhips"
          raise ArgumentError, message unless options[:except_relationships].is_a?(Array)

          associations.each_value do |relationship|
            relationship.class_name.constantize                                          # constantize dependant models
            if HasSearchIndex::MODELS.include?(relationship.class_name)
              options[:relationships] << relationship.name
            else
              message  = "#{error_prefix} relationship '#{relationship.name}' skipped,"
              message += " because '#{relationship.class_name}' model doesn't implements has_search_index plugin"
              logger.info(message)
            end
          end
          if !options[:except_relationships].empty?                                      # filter it if except_relationships isn't empty
            options[:except_relationships].each { |e| options[:relationships].delete(e) }
          end
        else
          message = "#{error_prefix} Warning you must type an array for :only_relationhips"
          raise ArgumentError, message unless options[:only_relationships].is_a?(Array)
          
          message = "#{error_prefix} Warning you mustn't specify both 'only_relationships' and 'except_relationships'"
          raise ArgumentError, message unless options[:except_relationships].empty?
          
          options[:only_relationships].each do |relationship_name|                       # constantize dependant models
            message = "#{error_prefix} Undefined relationship '#{relationship_name}', maybe you misspelled it"
            raise ArgumentError, message if self.reflect_on_association(relationship_name).nil?
            
            self.reflect_on_association(relationship_name).class_name.constantize
          end
          options[:relationships] = options[:only_relationships]
        end
        
        options[:relationships]
      end
      
      # Method called by +has_seach_index+ to check attributes configuration
      # return an Hash of checked attributes according to +options+
      # return an empty Hash if +except_attributes+ option contains :all symbol
      #
      def check_attributes(options, error_prefix)
        return {} if options[:except_attributes] == :all
        
        options[:attributes] = {}
        
        if options[:only_attributes].empty?
          tmp = Hash.new
          
          message = "#{error_prefix} Warning you must type an array or the symbol :all for :except_attributes"
          raise ArgumentError, message unless options[:except_attributes].is_a?(Array)
          
          self.columns.each do |element|
            options[:attributes] = options[:attributes].merge(element.name => element.type.to_s)
          end
          options[:attributes].delete_if {|n,x| match_regexp(n, "*_id")}                 # filter default attributes that are used as foreign key
          unless options[:except_attributes].empty?
            options[:except_attributes].each do |attribute|
              options[:attributes].delete_if {|n,x| match_regexp(n, attribute.to_s)}
            end
          end 
        else
          message = "#{error_prefix} :only_attributes is wrong. Expected Array but was #{options[:only_attributes].inspect}:#{options[:only_attributes].class.to_s}"
          raise ArgumentError, message unless options[:only_attributes].is_a?(Array)
          
          message = "#{error_prefix} Warning you mustn't specify both 'only_attributes' and 'except_attributes' options, please choose one"
          raise ArgumentError, message unless options[:except_attributes].empty?
          
          options[:only_attributes].each do |attribute|
            message = "#{error_prefix} Undefined attribute '#{attribute}', maybe you misspelled it"
            raise ArgumentError, message unless self.new.respond_to?(attribute.to_s)
            
            self.columns.each do |element|
              options[:attributes] = options[:attributes].merge(element.name => element.type.to_s) if element.name == attribute.to_s
            end
          end
        end
        options[:attributes]
      end
      
      # Method that return true if the +relationship+ have some options to be taken in account
      #
      def relationship_need_to_be_checked?(relationship, sql_options)
        association = self.reflect_on_association(relationship)
        association.macro != :belongs_to and (association.options.keys-sql_options).size < association.options.keys.size
      end
      
      # Method that check +relationships_options+ to take in account some ignored options when using eager loading (:order,:group,:limit...)
      #
      def check_relationships_options(relationships)
        
        sql_options   = [:group, :order, :limit]   # don't put :having because it is not implemented into rails 2.1.0, and :offset because it depend on :limit presence
        relationships = relationships.reject {|n| !relationship_need_to_be_checked?(n, sql_options)} # filter 'belongs_to' because there's no options usable with it
        
        relationships.each do |relationship|
          
          association = self.reflect_on_association(relationship)
          table       = self.quoted_table_name
          class_name  = association.class_name
          table_alias = "#{association.name.to_s}_#{self.table_name}" if (self.to_s == class_name)   # alias table when self referencing
          class_table = class_name.constantize.quoted_table_name
          foreign_key = association.options[:foreign_key] ||  "#{self.to_s.underscore}_id"
          primary_key = association.options[:primary_key] || "id"
          
          # options like :order or :conditions ...
          options = association.options
          
          # Has_and_belongs_to_many
          join_table              = "`#{options[:join_table]}`"
          association_foreign_key = (association.respond_to?('association_foreign_key'))? association.association_foreign_key : "#{class_name.underscore}_id"
         
          # polymorphique
          polymorphique_interface      = options[:as]
          polymorphique_interface_type = "'#{self.to_s}'"
          
          # TODO test relation with through pointing to a polymorphic to view the generated sql to know how to manage the source_type .
          source      = options[:source] || relationship.to_s
          source_type = options[:source_type] # for +has_one+ or +has_many+ pointing to a +belongs_to+ with ':polymorphic == true'
          
          # the relationship go through another one 
          unless options[:through].nil?     
            through             = options[:through]
            through_association = self.reflect_on_association(through)
            through_class_name  = through_association.class_name
            through_class_table = through_class_name.constantize.quoted_table_name
            # Manage N-N self reference
            default             = (self.to_s == class_name)? association.name.to_s.singularize : class_name.underscore
            through_fk          = through_association.options[:foreign_key] || "#{default}_id"
            through_pk          = through_association.options[:primary_key] || "id"
            through_polymorphique_interface = through_association.options[:as]
          end
          
          sql = "SELECT #{class_table}.id FROM #{class_table}"
           
          case association.macro
          
            when :has_one, :has_many
              join_end = through.nil? ? "#{class_table}." : "#{through_class_table}."
              
              unless through.nil?       
                sql += " INNER JOIN #{through_class_table} ON #{class_table}.#{through_pk} = #{through_class_table}.#{through_fk}"                
                if through_polymorphique_interface.nil?
                  join_end    += "#{foreign_key}"
                else
                  join_end    += "#{through_polymorphique_interface}_id"
                  where_clause = " WHERE (#{through_class_table}.#{through_polymorphique_interface}_type = #{polymorphique_interface_type})"
                end             
              else
                if polymorphique_interface.nil?
                  join_end    += "#{foreign_key}"
                else
                  join_end    += "#{polymorphique_interface}_id"
                  where_clause = " WHERE (#{class_table}.#{polymorphique_interface}_type = #{polymorphique_interface_type})"
                end               
              end
              
            when :has_and_belongs_to_many
              sql     += " INNER JOIN #{join_table} ON #{class_table}.#{primary_key} = #{join_table}.#{association_foreign_key}"
              join_end = "#{join_table}.#{foreign_key}"
          end
          
          table_with_alias = table_alias.nil? ? "#{table} ON #{table}" : "#{table} #{table_alias} ON #{table_alias}"
          sql += " LEFT OUTER JOIN #{table_with_alias}.#{primary_key} = #{join_end}"
          
          # where
          sql += where_clause unless where_clause.nil?         
          
          # FIXME remove that raise when mysql's subquery error will be fixed
          message  = "#{self::ERROR_PREFIX} #{association.macro} :#{association.name} -> " 
          message += ":LIMIT is not supported yet by mysql into subqueries 'http://dev.mysql.com/doc/refman/5.0/en/subquery-errors.html'"
          raise ArgumentError, message if association.macro != :has_one and !options[:limit].nil?
          ##################################################################
          
          sql_options.each do |option|     
            case option
              when :group
                sql += " GROUP BY #{class_table}.#{options[:group].to_s.split('.').last}" unless options[:group].nil? or association.macro == :has_one
              when :order
                sql += " ORDER BY #{class_table}.#{options[:order].to_s.split('.').last}" unless options[:order].nil?
              when :limit
                sql += (association.macro == :has_one)? ' LIMIT 1' : add_limit_offset!('', {:limit => options[:limit], :offset => options[:offset]})
            end
            self.reflect_on_association(relationship).options.delete(option)
          end
          
          operator  = (association.macro == :has_one)? '=' : 'in'
          statement = "#{class_table}.#{primary_key} #{operator} (#{sql})"
          if options[:conditions].nil?
            self.reflect_on_association(relationship).options[:conditions]     = statement.to_a
          else
            self.reflect_on_association(relationship).options[:conditions][0] += " AND #{statement}"
          end
        end       
      end
      
      ###################################################################################
      
      # Method that permit to search for additional attributes
      # look for search_with() public method for examples
      # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
      # # 'search_type' is a string include into that range ["or","and","not"]
      #
      def search_additional_attributes(attributes, search_type)
        collection = self.all
        additional_result = (search_type == "or")? Array.new : collection                # initialization is different according to search type
                                                                                         #  because of using  & or | on arrays
        attributes.each_pair do |attribute,value|
          if is_additional?(attribute)
            tmp_result = Array.new
            collection.each do |object|
              if attribute.include?(".")                                                 # nested resource ex=> roles.name
                nested_resources = attribute.split(".")
                nested_attribute = nested_resources.pop
                nested_object    = get_nested_object(object, nested_resources)
                unless nested_object.nil?  
                  if nested_object.is_a?(Array)                                          # has many sub resources
                    nested_object.each do |sub_obj|
                      tmp_result << object if search_match?(sub_obj, nested_attribute, value, search_type)
                    end
                  else
                    tmp_result << object if search_match?(nested_object, nested_attribute, value, search_type)
                  end
                end
              else
                tmp_result << object if search_match?(object, attribute, value, search_type)
              end
            end
            (search_type == "or")? additional_result |= tmp_result : additional_result &= tmp_result
          end
        end
        additional_result
      end

      # Method to search into database for attributes
      # look for search_with() public method for examples
      # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
      # # 'search_type' is a string include into that range ["or","and","not"]
      #
      def search_database_attributes(attributes, search_type)
        conditions_array = [""]
        
        unless attributes.nil?
          prefixes      = attributes.keys.collect {|n| n.chomp(n.split('.').last).chomp('.')}.reject {|n| n.blank?}
          include_array = filter_include_array_from_prefixes(get_include_array, prefixes)
          
          attributes.each_pair do |attr_with_prefix, values|                             # +values+ can be a value or many values separated by spaces
            attr_with_prefix = attr_with_prefix.downcase
            unless is_additional?(attr_with_prefix)
              if attr_with_prefix.include?(".")                                          # check if the attribute come from a nested resource
                attribute        = attr_with_prefix.split(".").last
                attribute_path   = attr_with_prefix.chomp(".#{attribute}")
                attribute_prefix = generate_attribute_prefix("#{self.table_name}.#{attribute_path}", include_array)
                model            = relationship_class_name(attribute_path, attribute_path.split(".").last).constantize
              else
                attribute        = attr_with_prefix
                attribute_prefix = self.table_name
                model            = self
              end
     
              formatted_attribute = "#{attribute_prefix}.#{attribute}"                   # prefix attribute with the model that it depend on, to avoid ambiguous
              conditions_array    = get_conditions_array_for_criterion(model, values, formatted_attribute, search_type, conditions_array)
            end         
          end
          
          command = "#{self}.all(:include =>#{include_array.inspect}, :conditions =>#{conditions_array.inspect})"
          logger.debug "[#{DateTime.now}](has_search_index.rb l.#{__LINE__}) #{command}"
          return self.all(:include => include_array, :conditions => conditions_array)
        end
        []
      end
      
      # Method that return the conditions_array to be passed to the find call.
      # 
      def get_conditions_array_for_criterion(model, values, attribute, search_type, conditions_array=[''])
        
        operator         = (search_type == 'not')? 'and' : search_type                     # if +search_type+ is 'not', invert all actions and use 'and' search type
        condition_text   = ""
        attribute_without_prefix = attribute.split('.').last
        
        if !values.is_a?(Hash) and !values.is_a?(Array) 
          splited_values = split_value(model, attribute_without_prefix, values)          # manage the case when passing multiple values into a field 
          unless [nil,'',' '].include?(values)
            splited_values.each_with_index do |value, i|
              condition_text += " or " unless i == 0           
              condition_text += "#{attribute}"
              if model.search_index_attribute_type(attribute_without_prefix) == "string"
                condition_text   += ( search_type == "not" ? " #{self.negative('like')}?" : " like?")
                conditions_array << "%#{value}%"
              else
                condition_text   += ( search_type == "not" ? " #{self.negative('=')}?" : " =?")
                conditions_array << value
              end
            end
            conditions_array[0] << " #{operator} " unless conditions_array[0].blank?
            conditions_array[0] << "(#{condition_text})"
          end
        else
          value_array = (values.is_a?(Array))? values : [ values ]                       # manage the case when only one value for the attribute
          
          value_array.each do |option|                                                   # parse all values for one attribute
            condition_text = "" 
            splited_values = split_value(model, attribute_without_prefix, option[:value])  # manage the case when passing multiple values into a field
            
            unless [nil,'',' '].include?(option[:value])
              splited_values.each_with_index do |value, i|
                action              = (search_type == "not")? self.negative(option[:action]) : option[:action]
                seccondary_operator = ['like', '='].include?(action)? ' or ' : ' and '        
                condition_text     += seccondary_operator unless i == 0              
                condition_text     += "#{attribute} #{action}?"
                
                if ["like", "not like"].include?(option[:action])
                  conditions_array << "%#{value}%"
                else 
                  conditions_array << value
                end
              end
              conditions_array[0] << " #{operator} " unless conditions_array[0].blank?
              conditions_array[0] << "(#{condition_text})"
            end
          end
        end
        conditions_array
      end
      
      # Method to generate attribute prefix to put into conditions array
      # It is called by "search_database_attributes" method
      # ps : This method manage 3 levels of ambiguity like rails to create join relationships from ':include' hash into 'find'
      #      First it look the name of the last model, before the attribute that prefixed with that model's tablename to avoid ambiguity like:
      #       # =>  #{model_table_name}.attribute
      #      But in some cases there're two models but from two different parent models. When it's the case rails suffix the model table_name like:
      #       # =>  #{model_table_name}_#{parent_model_table_name}.attribute
      #      And in some cases if there's several times the same couple model/parent_model the suffix is indexed like:
      #       # =>  #{model_table_name}_#{parent_model_table_name}_#{i}.attribute
      #       with 'i' start at 2 for the first repetition of the same couple model/parent_model  
      # Attributes:
      #
      #   attribute_prefix => the brut attribute prefix from the search plugin
      #
      def generate_attribute_prefix(attribute_prefix, include_array)
        relationship     = attribute_prefix.split(".")[-2]
        sub_relationship = attribute_prefix.split(".")[-1]
        
        prefix_table     = get_prefix_order(self.table_name, include_array, sub_relationship, relationship)
        
        # filter the prefix table to get only the redundant prefixes according to the current prefix
        redundant_prefixes = prefix_table.reject {|n| !(n.split(".")[-2..-1] == attribute_prefix.split(".")[-2..-1]) or n == prefix_table.first}
        prefix_index       = redundant_prefixes.index(attribute_prefix)
        
        # OPTIMIZE maybe remove that comment if it's not necessary
        #  manage the pluralize with caution because pluralize do not works properly with plural strings that do not finish with one "s"
        #  and when you add a relationship into the include array, if there is a redundancy of that relationship the find seems to use 
        #  the pluralize method that add one 's' to already pluralize string like (children that come from services) become 'childrens_services'
        #  then to make the 'find' to work properly we have to respect the name given to the table joins aliases by the 'find' to be able to access to the 
        #  data.
        #  But that error concerne only the custom relationships name management, so if the relationship name refer to the model according to the relationship convention,
        # (plural if has_many and singular for belongs to for example), it will work properly with the plurals
        #  example :
        #   # => Employee.all(:include => [:premia], :conditions => ["premia.id =?",0])                     it will work
        #   # => Service.all(:include => [:children], :conditions => ["childrens_services.id =?",0])
        #        children is a service belonging to another service that's why there is a redundancy but the fact is that we need to add one 's'
        #        to 'chidren' to make it work properly.
        
        # manage the custom relationships name
        model     = relationship_class_name(attribute_prefix, relationship).tableize.singularize
        sub_model = relationship_class_name(attribute_prefix, sub_relationship).tableize.singularize
        
        if relationship_class_name(attribute_prefix, relationship) == relationship_class_name(attribute_prefix, sub_relationship)    # manage the self reference
          return "#{sub_relationship.pluralize}_#{relationship.pluralize}"
        end
               
        model     = model.pluralize unless model.plural?
        sub_model = sub_model.pluralize unless sub_model.plural?
        
        return "#{sub_model}" if prefix_table.first == attribute_prefix
        case prefix_index
          when nil
            raise "#{self::ERROR_PREFIX} AttributPrefixError: #{attribute_prefix} do not match with the plugin definition into the model"
          when 0
            return "#{sub_model.pluralize}_#{model.pluralize}"
          else
            return "#{sub_model.pluralize}_#{model.pluralize}_#{prefix_index+1}"
        end
      end
      
      # Method called by "generate_attribute_prefix" to parse recursively the include_array
      # It return an array of all prefixes usable according to the include array
      # permit to the calling method, to manage the prefix redundancy and to add indexes
      #
      def get_prefix_order(parent_model_tablename, include_array, sub_model, model, path="")
        prefix_table = []
        path        += "#{parent_model_tablename}."
        include_array.each do |element|
          if element.is_a?(Hash)
            current_model = element.keys[0].to_s
            prefix_table += get_prefix_order(current_model, element.values[0], sub_model, model, path)
          else
            current_model = element.to_s
          end
          prefix_table << "#{path}#{current_model}" if sub_model == current_model
        end
        prefix_table
      end
      
      # Method to permit model retrievement from a +relationship+
      # according to a +path+ ex :
      # # => Employee.retrieve_relationship_class("employees.numbers.number_type", "numbers") -> 'Number'
      #
      # # => Employee.retrieve_relationship_class("employees.numbers.number_type", "employees") -> 'Employee'
      #
      # the +path+ must begin by main model table_name (Employee -> 'employees') or a direct relationship (Employee has_many :numbers --> 'numbers')
      # # => Employee.retrieve_relationship_class("numbers.number_type", "numbers") -> 'Number'
      #
      def relationship_class_name(path, relationship)
        model = self
        return self.to_s if relationship == self.table_name
        path.gsub("#{self.table_name}.","").split(".").each do |e|
          return model.reflect_on_association(e.to_sym).class_name if e == relationship
          model = model.reflect_on_association(e.to_sym).class_name.constantize
        end
        nil
      end
      
      
      # Method that split strings into converted values array
      #
      # === examples
      #
      #  split_value(Employee.first, last_name, "jo hn")
      #  #=> ['jo', 'hn', 'jo hn']
      #
      #  split_value(User.first, enabled, "1 0 true")
      #  #=> [true, false, true]
      #
      #  split_value(User.first, username, "john D Doe \"john Doe\"")
      #  #=> ['john', 'D', 'Doe','john Doe', "john D Doe \"john Doe\""]
      #
      # OPTMIZE Maybe it can be optimized a little bit
      def split_value(model, attribute, value)
        prepared_value  = value.to_s.gsub('\"',"x22")
        formatted_value = prepared_value.gsub('"','').gsub('x22','"')
        raise ArgumentError, "Value '#{prepared_value}' is wrong. '\"' must be by pair" if prepared_value.count("\"")%2 == 1
        
        if prepared_value.include?('"')
          values = prepared_value.split('"')
          part1  = values.select {|n| values.index(n)%2 == 0}.join(' ').split(' ')
          part2  = values.select {|n| values.index(n)%2 == 1}                            # values surrounded by double-quotes
          values = part1 + part2
        else
          values = prepared_value.split(' ')         
        end
        values = values.collect {|n| n.gsub('x22','"')}

        case model.search_index_attribute_type(attribute)
          when 'boolean'
            return values.collect(&:to_b)
          when 'integer'
            return values.collect(&:to_i)
          when 'float', 'decimal'
            return values.collect(&:to_f)
          when 'datetime'
            return value.to_s.gsub('"','').to_a
          else
            return formatted_value.to_a.fusion(values)
        end
      end
  end

end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasSearchIndex)
end
