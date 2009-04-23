    module HasSearchIndex

      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end
      end

      module ClassMethods
        
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
      
          # check options arg for some errors
          raise 'Argument missing you must specify attributes like :attributes => ["attr1","attr2",etc...]' if options[:attributes].nil?
          options.keys.each do |key|
            raise "Unknown option :#{key.to_s}" unless [:attributes,:additional_attributes,:sub_models].include?(key)      
          end

          # permit to replace attribute name by an object containing sql informations such as name, type, etc...
          tmp = Hash.new
          options[:attributes].each do |a|
            raise "Unknown attribute #{a} please check it" unless self.new.respond_to?(a)
            self.columns.each do |elmnt|
              tmp = tmp.merge(elmnt.name => elmnt.type.to_s) if elmnt.name==a
            end
          end
          options[:attributes] = tmp
          options[:additional_attributes] ||= {}                              # create empty Hash if don't exist

          # create class var to permit to access to search option from te model
          class_eval do
            cattr_accessor :search_index
            self.search_index = options 
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
            if tmp.pluralize == tmp
              object = tmp.singularize.camelize.constantize
            else
              object = tmp.camelize.constantize
            end
            attribute = attribute.split(".").last            
          else
            object = self
          end
          raise "Implementation error #{object} model must implement has_search_index plugin in order to use directly or undirectly the plugin" unless object.respond_to?("search_index")
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
        # match?(employee.first,"first_name","jean")
        # ==> return employee  like -> employee.frist_name=="jean"
        #
        def match?(object,attribute,value)
          attributes = self.search_index[:additional_attributes]
          data = object.send(attribute).to_s
          return false if data.nil?
          if !value.is_a?(Hash)
            if object.search_index[:additional_attributes][attribute]=="string"          #  use regexp for string attributes same that use like into sql queries
              return data.downcase.match(Regexp.new(value.to_s.downcase))               #  downcase data and value to make the match method case insensitive
            else
              return data == value.to_s
            end
          end       
          raise ArgumentError, "Argument missing into value hash : if you use the value hash instead of value you must type it like {:value => foo :action => bar} " if value[:action].nil?           

          if value[:action] == "like"
            return data.downcase.match(Regexp.new(value[:value].downcase))              #  downcase data and value to make the match method case insensitive
          elsif value[:action] == "not like"
            return !data.downcase.match(Regexp.new(value[:value].downcase))             #  downcase data and value to make the match method case insensitive
          elsif value[:action] == "!="
            return !data.send("==",value[:value].to_s)
          elsif value[:action] == "="
            return data.send("==",value[:value].to_s)
          elsif ACTIONS[attributes[attribute].to_sym].include?(value[:action])
            return data.send(value[:action],value[:value].to_s)
          else
            raise ArgumentError, "unproper operator '#{value[:action]}' for #{attributes[attribute]} datatype"
          end
          
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
          nested_resources.each do |r|
            if object.is_a?(Array)
              tmp = Array.new
              object.each do |o|
                  if o.send(r).is_a?(Array)
                    tmp = tmp.fusion(o.send(r))
                  else
                    tmp << o.send(r)
                  end          
              end
              object = tmp
            else              
              object = object.send(r)
            end          
          end
          return object
        end

        # Method that permit to search attributes that are or not into database
        # You can access to the :action possible values into ACTIONS constant hash with the data type as key
        # for example ==> ACTIONS[:string] ==> ["not like","like","==","!="]
        #
        #==== example:
        #
        ## with an attribute that is not into database
        #
        #     User.search_with("expired?" => true)       or User.search("expired" => {:value => true :action => "="})
        #     => all users like an_user.expired?==true
        #
        ## with a nested attribute into database or not
        #(!) you must type the attribute in plural if the resource has many or has and belongs to many and in singular if the resource has one
        #
        #    #  User Has and belongs to many Role
        #     User.search_with("roles.name" => "admin")
        #     => all users that one role name is equal to "admin" at least 
        #      
        #    # Employee Has one JobContract
        #     Employee.search_with("job_contract.start_date" => "2/2/1900")
        #     => nothing because the date is to old, there's no user that have a job_contract's start_date equal to that one
        #
        #    # Customer has many Establishment and Establishment Has one Address
        #     Customer.search_with("establishments.address.zip_code" => 97438)
        #     => return all customers that have an establishments with zip code equal to 97438
        #
        def search_with(attributes={})
   
          if !attributes.is_a?(Hash)
            attribute_value = attributes
            attributes = Hash.new
            
            self.search_index[:attributes].merge( self.search_index[:additional_attributes]).each_key do |attribute|
              attributes = attributes.merge({attribute => attribute_value})
            end
            search_type = "or"
          else
            attributes[:search_type].nil? ? search_type = "and" : search_type = attributes.delete(:search_type)    # default value for the search type if not precised  
            attributes.each_key do |att|
              
              if att.split(".")[-2].camelize.plural?
                model = att.split(".")[-2].camelize.singularize.constantize
              else
                model = att.split(".")[-2].camelize.constantize
              end
## you must test for the model and his sub models if countaining the attribute
              txt = "You can't search for attribute '#{att.split(".").last}', because it's not indexed into #{model.to_s} model"          
              unless search_index[:attributes].include?(att.split(".").last) or model.search_index[:additional_attributes].include?(att.split(".").last)              
                raise ArgumentError ,txt
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
        
#        private
          
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
              tmp = Array.new             
              collection.each do |object|                                                                
                  if attribute.include?(".")                                                         # nested resource ex=> roles.name                        
                    nested_resources = attribute.split(".")                 
                    nested_attribute = nested_resources.pop
                    nested_object = get_nested_object(object, nested_resources)
                    if nested_object.is_a?(Array)                                                    # has many sub resources
                      nested_object.each do |sub_obj|
                        tmp << object if match?(sub_obj, nested_attribute, value)                  
                      end
                    else
                      tmp << object if match?(nested_object, nested_attribute, value)                      
                    end        
                  else
                    tmp << object if match?(object, attribute, value)
                  end            
              end
              additional_result = additional_result | tmp  if search_type=="or"                                         # get results that respond to one criterion at least
              additional_result = additional_result & tmp  if search_type=="and"                                        # get results that respond to all criteria
              end
            end
            additional_result = collection - additional_result if search_type == "not" and is_additional?(attribute)    # get results that don't respond to all criteria

            return additional_result
          end

          # Method to search into database for attributes
          # look for search_with() public method for examples
          # # 'attributes' is an array like ["attribute" => "value", etc...] or ["attribute"=> {:value => "value", :action => "="}]
          # # 'search_type' is a string include into that range ["or","and","not"]
          #
          def search_database_attributes(attributes, search_type)
            conditions_array = [""]
            unless attributes.nil?
              attributes.each_pair do |attribute,value|
                unless is_additional?(attribute)
                  if attribute.include?(".")
                    tmp = attribute.split(".")[-2]                                                               # -2 point to the second element from the end of the array
                    if tmp.pluralize == tmp
                      model = tmp.singularize.camelize.constantize
                    else
                      model = tmp.camelize.constantize
                    end
                    good_attribute = model.new.respond_to?(attribute.split(".").last)
                  else
                    good_attribute = self.new.respond_to?(attribute)
                  end
                  if good_attribute
                    conditions_array[0] << " #{search_type} " unless conditions_array[0]==""
                    formatted_attribute = "#{model.table_name}." unless model.nil?
                    formatted_attribute = "#{attribute.split(".").last}"                                         # to get a nested resource => table_name.nested_resource
                    if value.is_a?(Hash)
                      conditions_array[0] << "#{formatted_attribute} #{value[:action]}?"
                      if value[:action] == "like" or value[:action] == "not like"
                        conditions_array << "%#{value[:value]}%"
                      else 
                        conditions_array << value[:value]
                      end
                    else
                      conditions_array[0] << "#{formatted_attribute}"
                      if search_index[:attributes][attribute.split(".").last]=="string"
                        conditions_array[0] << " like?"
                        conditions_array << "%#{value}%"
                      else
                        conditions_array[0] << " =?"
                        conditions_array << value
                      end
                    end
                  else
                    raise ArgumentError,  "Wrong argument #{a} maybe you misspelled it"
                  end
                end 
              end
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
