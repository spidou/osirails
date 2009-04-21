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
            object = attribute.split(".")[attribute.split(".").size-2].singularize.camelize.constantize
            attribute = attribute.split(".").last            
          else
            object = self
          end
          raise "Implementation error #{object} model must implement has_search_index plugin in order to use directly or undirectly the plugin" unless object.respond_to?("search_index")
          return false if object.search_index[:additional_attributes].nil?
          
          object.search_index[:additional_attributes].include?(attribute)
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
            return include_array
          end
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
          data = object.send(attribute)
          return false if data.nil?
        
          return data == value unless value.is_a?(Hash)          
          raise ArgumentError, "Argument missing into value hash : if you use the value hash instead of value you must type it like {:value => foo :action => bar} " if value[:action].nil?           

          if value[:action] == "like"
            return data.match(Regexp.new(value[:value]))   
          elsif value[:action] == "not like"
            return !data.match(Regexp.new(value[:value]))
          elsif value[:action] == "!="
            return !data.send("==",value[:value])
          elsif value[:action] == "="
            return data.send("==",value[:value])
          elsif ACTIONS[attributes[attribute].to_sym].include?(value[:action])
            return data.send(value[:action],value[:value])
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
        #     User.search("expired?" => true)       or User.search("expired" => {:value => true :action => "=="})
        #     => all users like an_user.expired?==true
        #
        ## with a nested attribute
        #
        #     User.search("roles.name" => "admin")
        #     => all users that one role name is equal to "admin" at least 
        #
        def search(attributes={})
          collection = self.find(:all)
          attributes[:search_type].nil? ? search_type = "and" : search_type = attributes.delete(:search_type)    # default value for the search type if not precised
          search_type=="or" ? additional_result = Array.new : additional_result = collection                     # initialization is different according to search type because of using  & or | on arrays

          # search for additional attributes
          # ################################
          attributes.each_pair do |attribute,value|
            tmp = Array.new             
            collection.each do |object|
              if is_additional?(attribute)                                                      
                if attribute.include?(".")                                                                      # nested resource ex=> roles.name                        
                  nested_resources = attribute.split(".")                 
                  nested_attribute = nested_resources.pop
                  nested_object = get_nested_object(object, nested_resources )
                  if nested_object.is_a?(Array)                                                                 # has many sub resources
                    nested_object.each do |sub_obj|
                      tmp << object if match?(sub_obj, nested_attribute, value)                  
                    end
                  else
                    tmp << object if match?(nested_object, nested_attribute, value)                      
                  end        
                else
                  tmp << object if match?(object,attribute,value)
                end
                attributes.delete(attribute)
              end
            end
            additional_result = additional_result | tmp  if search_type=="or"                             # get results that respond to one criterion at least
            additional_result = additional_result & tmp  if search_type=="and"                            # get results that respond to all criteria
          end
          additional_result = collection - additional_result if search_type == "not"                      # get results that don't respond to all criteria


          # search for attributes into database
          ##################################### 
          conditions_array = [""]
          unless attributes.nil?
            attributes.each_pair do |attribute,value|
              # TODO improve error detections for nested resources if the attribute respond to the last resource it works but we don't verify the other nested resources for example : job_contact.job_contract_type.name will work because name respond to job_contract_type even if job_contact* is wrong     (*job_contract)
              if attribute.include?(".")
                model = attribute.split(".")[attribute.split(".").size-2].camelize.constantize
                good_attribute = model.new.respond_to?(attribute.split(".").last)
              else
                good_attribute = self.new.respond_to?(attribute)
              end
puts "yes" if good_attribute 
              if good_attribute
puts search_type
                conditions_array[0]<< " #{search_type} " unless conditions_array[0]==""
puts " before condition_array[0] = #{conditions_array[0]}"
                if value.is_a?(Hash)
                  conditions_array[0]<<"#{attribute} #{value[:action]}?"
                  if value[:action]=="like" or value[:action]=="not like"
                    conditions_array << "%#{value[:value]}%"
                  else 
                    conditions_array << value[:value]
                  end
                else
                  conditions_array[0]<<"#{attribute} =?"
                  conditions_array << value
                end
puts "after condition_array[0] = #{conditions_array[0]}"
                
puts "condition_array = #{conditions_array.inspect}"
              else
                raise ArgumentError,  "Wrong argument #{a} maybe you misspelled it"
              end
              return self.find(:all ,:include => get_include_array, :conditions => conditions_array)
            end
          end
      
          return additional_result
          

        end

        def find_with(exp,opt={})
          if opt=={}
            conditions_array = [""]
            options[:attributes].each do |a|
              if( self.new.respond_to?(a) and self.new.a.class)
    		        conditions_array[0]<<" or " unless conditions_array[0]==""
    		        conditions_array[0]<<"#{a} like ?"
    		        conditions_array << exp
    		      end
            end
            return self.find(:all,:conditions => conditions_array)
          end
        end

      end

    end

    # Set it all up.
    if Object.const_defined?("ActiveRecord")
      ActiveRecord::Base.send(:include, HasSearchIndex)
    end
