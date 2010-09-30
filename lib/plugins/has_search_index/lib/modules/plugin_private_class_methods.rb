module PrivateClassMethods

# basics_overrides dependencies
## Array
# same_elements?
# include_all_values?
# fusion
#
## Hash
# fusion
#
## String
# to_b
#
## Reverser (the whole class) 
#
## Object
# rev
private
  
  # Method that true if all criterion's attribute are additional
  # return false if there's no criteria or at least one isn't additional
  #
  def only_additional_attributes?(criteria)
    return false if criteria.empty?
    criteria.each_key {|attribute| return false unless is_additional?(attribute)}
    true
  end

  # Method that true if all criterion's attribute are not additional
  # return false if there's no criteria or at least one is additional
  #
  def only_database_attributes?(criteria)
    return false if criteria.empty?
    criteria.each_key {|attribute| return false if is_additional?(attribute)}
    true
  end
    
  # Method to identify if an attribute belongs to the additionals attributes
  # return true if it do and false if not
  #
  def is_additional?(attribute_with_path)
    attribute_path = extract_path(attribute_with_path.downcase)
    attribute      = extract_attribute(attribute_with_path.downcase)
    object         = self
    if attribute_path
      attribute_path.split(".").each do |relationship|
        object = object.reflect_relationship(relationship, check_implicit = true)
      end
    end
    
    object.search_index[:additional_attributes].include?(attribute)
  end
  
  # Method that check the search_type if it is in range (and, or, not)
  # and permit to manage the case when search_type is not a string and to make it 'case insensitive'
  #
  def get_valid_search_type(type)
    return 'and' unless type
    message = "#{self::ERROR_PREFIX} search_type must be in ('and', 'or', 'not')" 
    raise(ArgumentError, message) unless ['and', 'or', 'not'].include?(type.to_s.downcase)
    
    return type.to_s.downcase
  end
  
  ## Method to return checked order Array
  #
  def get_valid_order_clause(order)
    return [] if order.nil?
    mess_start = "#{self::ERROR_PREFIX} Wrong order clause '#{ order.inspect }'."
    message = "#{ mess_start } Expected to be an Array"
    raise(ArgumentError, message)unless order.is_a?(Array)
    order.each do |element|
      if ['desc','asc'].include?((element.split(':').at(1) || 'asc').strip.downcase)
        check_criterion_attribute(element.split(':').at(0).strip.downcase)
      else
        raise(ArgumentError, "#{ mess_start } Expected to be like 'ATTRIBUTE:DIRECTION', DRECTION in (Desc, Asc)")
      end
    end
    order
  end
  
  ## Method to return checked group Array
  #
  def get_valid_group_clause(group)
    return [] if group.nil?
    
    message = "#{self::ERROR_PREFIX} Wrong group clause '#{ group.inspect }'. Expected to be an Array"
    raise(ArgumentError, message) unless group.is_a?(Array)
    group.each do |element|
      check_criterion_attribute(element)
    end
    group
  end
  
  def get_valid_criteria_from_quick_search(quick)
    result = {}
    return result unless quick
    message = "#{self::ERROR_PREFIX} Wrong quick clause '#{ quick.inspect }'. Expected to be a Hash"
    raise(ArgumentError, message) unless quick.is_a?(Hash)
    message = "#{self::ERROR_PREFIX} Wrong quick clause '#{ quick.inspect }'. Expected to be like {:attributes => Array, :value => String}"
    raise(ArgumentError, message) unless quick.keys.include_all?([:value, :attributes])
    
    quick[:attributes].each {|attribute| result[attribute] = quick[:value]}
    result
  end
  
  # Method to match a simple regexp with a data string
  # to match a data that end with 'x' 
  #  #=> "*x"
  # to match a data that start with 'x'
  #  #=> "x*"
  # to match a data that contain 'x'
  #  #=> "*x*"
  # if there's no * then the regexp wil be the exp passed as argument
  #
  def match_regexp(data, exp)
    string = exp.gsub("*","")
    regexp = "^#{ string }$"
    regexp = "#{ string }$" if exp.first == "*"
    regexp = "^#{ string }" if exp.last == "*"
    regexp = "#{ string }" if exp.last == "*" and exp.first == "*"
    return !data.match(Regexp.new(regexp)).nil?
  end

  # Method that filter a given include_array according to attribute's prefixes given in arguments
  #
  def filter_include_array_from_paths(include_array, prefixes, level = 0)
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
          nested  = filter_include_array_from_paths(element[symbol], prefixes, level + 1)     
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
    message  = "#{self::ERROR_PREFIX} Implementation error '#{object}' model must implement has_search_index"
    message += " plugin in order to use directly or undirectly the plugin"
    attribute  = attribute.downcase
    attributes = self.search_index[:additional_attributes]
    data       = object.send(attribute).to_s.downcase                                  # downcase data to make the match method case insensitive
    is_match   = nil

    return false if data.nil?
    if !values.is_a?(Hash) and !values.is_a?(Array)
      splited_values = split_value(object.class, attribute, values)                    # permit to manage when passsing multiple values in the same field

      splited_values.each do |value|
        value        = value.to_s.downcase                                             # downcase value to make the match method case insensitive
        is_string    = ["string", "text"].include?(object.class.search_index_attribute_type(attribute))
        is_match ||= is_string ? data.match(Regexp.new(value)) : data == value
      end
      return (search_type == 'not')? !is_match : is_match
    end

    value_array = (values.is_a?(Array))? values : [ values ]                           # manage the case when only one attribute
        
    
    value_array.each do |val|
      message  = "#{self::ERROR_PREFIX} Argument missing into value hash :"
      message += " if you use the value hash instead of value you must type it like {:value => foo :action => bar} "
      raise(ArgumentError, message) if val[:action].nil?
      
      splited_values = split_value(object.class, attribute, val[:value])               # permit to manage when passsing multiple values in the same field 
      tmp_match     = nil
      
      splited_values.each do |value|
        is_like  = !data.match(Regexp.new(value.to_s.downcase)).nil?                   # downcase value to make the match method case insensitive
        is_equal = data.send("==", value.to_s.downcase)

        if ['not like', '!='].include?(val[:action])
          tmp_match = true                                                            # initialise tmp_match to true because of using '&&='
          tmp_match &&= (val[:action] == '!=')? !is_equal : !is_like
        elsif ['like', '='].include?(val[:action])
          tmp_match ||= (val[:action] == '=')? is_equal : is_like
        elsif HasSearchIndex::ACTIONS[attributes[attribute].to_sym].include?(val[:action])
          tmp_match ||= data.send(val[:action], value.to_s.downcase)
        else
          raise(ArgumentError, "#{self::ERROR_PREFIX} Unproper operator '#{val[:action]}' for #{attributes[attribute]} datatype")
        end
        tmp_match = !tmp_match if search_type == 'not'
      end
      
      is_match = tmp_match if is_match.nil? 
      search_type == 'or' ? is_match |= tmp_match : is_match &= tmp_match
    end
    
    return is_match
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
    raise(ArgumentError, "Expected Array but was '#{nested_resources}':#{nested_resources.class.to_s}") unless nested_resources.is_a?(Array)
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
  #
  # +value+ -> the searched value 
  # ==== example :
  #
  # get_criteria_for_simple_search("value")
  # => {"attribute1"=>"value", "attribute2"=>"value", ect...}
  #
  def get_criteria_for_simple_search(value)
    attributes = Hash.new
    self.search_index_attributes.each_key {|attribute| attributes.merge!({attribute => value}) }
    attributes.merge!(:search_type => 'or')
    attributes
  end

  # method to get the negative form of the comparators ex != for =
  #
  def negative(action)
    positive = ["=",">","<","like"]
    negative = ["!=","<=",">=","not like"]
    return negative[positive.index(action)] if positive.include?(action)
    return positive[negative.index(action)] if negative.include?(action)
  end
  
  # Method to check attribute part of a criterion
  #
  def check_criterion_attribute(attribute_with_prefix)
    attribute = attribute_with_prefix.split(".").last
    model     = self
    
    # check relationship and get the model where to verify the attribute
    if attribute_with_prefix.include?(".")                                                              
      prefix = attribute_with_prefix.chomp(".#{attribute}")
      prefix.split(".").each do |relationship|
        prefix_mess = ( prefix.include?('.') ? "into '#{prefix}'" : '' ) 
        message     = "#{self::ERROR_PREFIX} Association '#{relationship}' #{ prefix_mess }, undefined for has_search_index into '#{model.to_s}' model"
        raise(ArgumentError, message) unless model.search_index_relationships.include?(relationship.to_sym)
        model = model.reflect_relationship(relationship, check_implicit = true)
      end
    end
    
    # check the attribute
    message = "#{self::ERROR_PREFIX} Attribute '#{attribute}', undefined for has_search_index into '#{model.to_s}' model"
    raise(ArgumentError, message) unless model.search_index_attributes.include?(attribute)
  end

  # Method to check values part of criterion
  #
  def check_criterion_values(values)
    message = "#{self::ERROR_PREFIX} Wrong value '#{ values.inspect }:#{ values.class }'"
    if values.is_a?(Array)
      values.each do |value|
        if value.is_a?(Hash)
          raise(ArgumentError, "#{ message } each complex value should contain (:action, :value)") unless value.symbolize_keys.keys.same_elements?([:value, :action])
        end
      end
    elsif values.is_a?(Hash)
      raise(ArgumentError, "#{ message } complex value Hash should contain (:action, :value)") unless values.symbolize_keys.keys.same_elements?([:value, :action])
    end
  end
  
  # Method that permit to search for additional attributes
  # look for search_with() public method for examples
  #
  def search_with_additional_attributes(criteria, search_type)
    return [] if only_database_attributes?(criteria)
    
    collection        = self.all
    additional_result = (search_type == "or")? Array.new : collection              # initialization is different according to search type
                                                                                   # because of using  & or | on arrays
    criteria.each_pair do |attribute, value|
      next unless is_additional?(attribute)
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
    
    return additional_result
  end

  # Method to search into database for attributes
  # look for search_with() public method for examples
  #
  def search_with_database_attributes(criteria, search_type, order, group, quick)
    return [] if only_additional_attributes?(criteria) 
    
    include_option    = generate_include_option(criteria.merge(quick), group, order)
    conditions_option = generate_conditions_option(criteria, include_option, search_type)
    if quick.any?
      quick_conditions = generate_conditions_option(quick, include_option, (search_type == 'not' ? 'not' : 'or'))
      if quick_conditions != ['']
        conditions_option[0] += " #{ (search_type == 'not' ? 'not' : search_type) unless conditions_option[0].blank? } (#{ quick_conditions.shift })"
        conditions_option    += quick_conditions
      end
    end
    order_option      = generate_order_option(group, order, include_option)
    arguments         = { :include => include_option, :conditions => conditions_option }
    arguments[:order] = order_option.join(' ,') unless order_option.empty?
    
    logger.debug "[#{DateTime.now}](#{ File.dirname(__FILE__) }/plugin_private_class_methods.rb l.#{__LINE__}) : #{ self }.all(#{ arguments.inspect })"
    return self.all(arguments)
  end
  
  # Method that return order option to be passed to find
  #
  def generate_order_option(group, order, include_array)
    order_clause = []
    (group + order).each do |option|
      column    = HasSearchIndex.get_order_attribute(option)
      direction = HasSearchIndex.get_order_direction(option)
      next if is_additional?(column)
      order_clause << "#{ format_attribute_for_sql(column, include_array) } #{ direction }"
    end
    order_clause.push("#{ format_attribute_for_sql('id', include_array) } Asc")   # to order records at least by their id
  end
  
  # Method that return include option to be passed to find
  #
  def generate_include_option(criteria, group, order)
    paths  = criteria.keys.collect {|attribute_with_path| extract_path(attribute_with_path) }
    paths += (order + group).collect {|attribute_with_path| extract_path(HasSearchIndex.get_order_attribute(attribute_with_path)) }
    filter_include_array_from_paths(get_include_array, paths.reject(&:blank?))
  end
  
  # Method that return conditions option to be passed to find
  #
  def generate_conditions_option(criteria, include_array, search_type)
    conditions_array = ['']
    criteria.each do |attribute_with_path, values|                           # +values+ can be a value or many values separated by spaces
      next if is_additional?(attribute_with_path)
      
      if attribute_with_path.include?('.')
        relationship = attribute_with_path.split('.').at(-2)
        model = relationship_class_name_from(attribute_with_path, relationship).constantize
      else
        model = self
      end
      
      formatted_attribute = format_attribute_for_sql(attribute_with_path.downcase, include_array)
      conditions_array    = conditions_array(model, values, formatted_attribute, search_type, conditions_array)
    end
    
    conditions_array
  end
  
  ## Method to extract path from attribute_with_path
  # ==== example
  #
  ## => extract_attribute('relationship.attribute')  ==> 'relationship' 
  ## => extract_attribute('attribute')  ==> nil 
  #
  def extract_path(attribute_with_path)
    return nil unless attribute_with_path.include?('.')
    attribute = attribute_with_path.split('.').last
    return attribute_with_path.chomp(".#{ attribute }")
  end
  
  ## Method to extract attribute from attribute_with_path
  # ==== example
  #
  ## => extract_attribute('relationship.attribute')  ==> 'attribute'
  ## => extract_attribute('attribute')  ==> 'attribute'
  #
  def extract_attribute(attribute_with_path)
    return attribute_with_path.split('.').last
  end
  
  # Method to prepare an attribute to be added to where claue of a sql query
  #
  def format_attribute_for_sql(attribute_with_path, include_array)
    attribute_sql_prefix = if attribute_with_path.to_s.include?('.')                      # check if the attribute come from a nested resource
      generate_attribute_prefix("#{self.table_name}.#{ extract_path(attribute_with_path) }", include_array)
    else
      self.table_name
    end
    
    return "#{ attribute_sql_prefix }.#{ extract_attribute(attribute_with_path) }"
  end
  
  # Method that order and group +records+ according to +order+ and +group+
  #
  # +order+ -> Array:colelction of attributes with order direction ex => [attribute:desc, attribtue2:asc]
  # +group+ -> Array:collection of attributes
  #
  def group_and_order(records, order, group)
    sort = (group + order).map {|n| [HasSearchIndex.get_order_attribute(n).split('.') ,HasSearchIndex.get_order_direction(n)]}
    return records if sort.empty?
    records.sort_by do |a|                                                               # "push(a.id)" => to order records at least by their id
      sort.map {|n| n.last == 'desc' ? get_nested_object(a, n.first).to_s.rev : get_nested_object(a, n.first).to_s }.push(a.id)
    end
  end
  
  
  # Method to format sql condition
  #
  # +model+                 -> Object:last_relationship before attribute
  # +attribute_with_prefix+ -> String:attribute with path like "some_path_attribute"
  # +action+                -> String:see HasSearchIndex::ACTIONS
  # +value+                 -> value to search
  #
  def sql_condition(attribute_with_prefix, action, value, model)
    attribute = attribute_with_prefix.split('.').last
    condition_end = ['not like','!='].include?(action) ? "AND #{ attribute_with_prefix } IS NOT NULL" : "OR #{ attribute_with_prefix } IS NULL"
    if model.search_index_attribute_type(attribute) == 'boolean' && ['false', '0'].include?(value.to_s)
      "(#{ attribute_with_prefix } #{ action }? #{ condition_end })"
    elsif value.blank?
      "(#{ attribute_with_prefix } #{ action } '' #{ condition_end })"
    else
      "#{ attribute_with_prefix } #{ action }?"
    end
  end
  
  
  # Method that return the conditions_array to be passed to the find call.
  #
  # +model+                 -> Object:last_relationship before attribute
  # +attribute_with_prefix+ -> String:attribute with path like "some_path_attribute"
  # +search_type+           -> String:search_type in ('not','and','or')
  # +conditions_array+      -> Array:uncomplete or empty conditions_array
  #
  def conditions_array(model, values, attribute_with_prefix, search_type, conditions_array=[''])
    operator       = search_type == 'not' ? 'and' : search_type                          # if +search_type+ is 'not', invert all actions and use 'and' search type
    attribute      = attribute_with_prefix.split('.').last
    attribute_type = model.search_index_attribute_type(attribute)
    values_array   = (values.is_a?(Array))? values : [ values ]                          # handle many values for one attribute
    
    values_array.each do |option|
      if option.is_a?(Hash)                                                              # handle simple or complex option
        value  = option[:value]
        action = option[:action]
      else
        value  = option
        action = attribute_type == "string" ? 'like' : '='
      end
      
      action       = search_type == "not" ? negative(action) : action                    # handle 'not' search_type
      value_parts  = split_value(model, attribute, value)                                # handle when passing multiple values into a text field
      sec_operator = ['like', '='].include?(action) ? ' or ' : ' and '
      conditions   = []
      
      value_parts.each do |part|
        sql_condition     = sql_condition(attribute_with_prefix, action, part, model)
        conditions_array << (action =~ /like/ ? "%#{ part }%" : part) if sql_condition.include?('?')
        conditions       << sql_condition
      end
      conditions_array[0] += " #{ operator } " unless conditions_array[0].blank?
      conditions_array[0] += "(#{ conditions.join(sec_operator) })"
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
  #
  # +attribute_prefix+ => the brut attribute prefix from the search plugin
  #
  def generate_attribute_prefix(attribute_prefix, include_array)
    relationship     = attribute_prefix.split(".")[-2]
    sub_relationship = attribute_prefix.split(".")[-1]
    
    model     = relationship_class_name_from(attribute_prefix, relationship).constantize
    sub_model = relationship_class_name_from(attribute_prefix, sub_relationship).constantize
    table     = model.table_name
    sub_table = sub_model.table_name
    
    prefix_array = get_prefix_order(self.table_name, include_array, sub_table)
    
    # filter the prefix table to get only the redundant prefixes according to the current prefix
    redundant_prefixes = prefix_array.reject {|n| !(n.split(".")[-2..-1] == attribute_prefix.split(".")[-2..-1]) or n == prefix_array.first}
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
    
    basic_prefix = (table == sub_table && model == sub_model) ? "#{ sub_relationship.pluralize }_#{ relationship.pluralize }" : "#{ sub_table }_#{ table }"
    
    return sub_table if prefix_array.first == attribute_prefix
    case prefix_index
      when nil
        raise "#{self::ERROR_PREFIX} AttributePrefixError: '#{ attribute_prefix }' do not match with the plugin definition into the model"
      when 0
        return basic_prefix
      else
        return "#{ basic_prefix }_#{ prefix_index + 1 }"
    end
  end
  
  # Method called by "generate_attribute_prefix" to parse recursively the include_array
  # It return an array of all prefixes usable according to the include array
  # permit to the calling method, to manage the prefix redundancy and to add indexes
  #
  def get_prefix_order(parent_model_table_name, include_array, sub_model_table_name, path="")
    prefix_array = []
    path        += "#{parent_model_table_name}."
    include_array.each do |element|
      relationship  = element.is_a?(Hash) ? element.keys[0].to_s : element.to_s
      
      prefix_array  = complete_prefix(relationship, prefix_array, sub_model_table_name, path)
      prefix_array += get_prefix_order(relationship, element.values[0], sub_model_table_name, path) if element.is_a?(Hash)
    end
    return prefix_array
  end
  
  def complete_prefix(relationship, prefix_array, sub_table, path)
    table = relationship_class_name_from("#{ path }#{ relationship }", relationship).constantize.table_name
    return (sub_table == table ? prefix_array + ["#{ path }#{ relationship }"] : prefix_array)
  end
  
  # Method to permit model retrievement from a +relationship+
  # according to a +path+ ex :
  # # => Employee.relationship_class_name_from("employees.numbers.number_type", "numbers") -> 'Number'
  #
  # # => Employee.relationship_class_name_from("employees.numbers.number_type", "employees") -> 'Employee'
  #
  # # => Employee.relationship_class_name_from("employees.numbers.number_type", :employees) -> 'Employee'
  #
  # the +path+ must begin by main model table_name (Employee -> 'employees') or a direct relationship (Employee has_many :numbers --> 'numbers')
  # # => Employee.retrieve_relationship_class("numbers.number_type", "numbers") -> 'Number'
  #
  def relationship_class_name_from(path, relationship)
    model = self
    return self.to_s if relationship == self.table_name
    path.gsub("#{self.table_name}.","").split(".").each do |part|
      if model.reflect_on_association(part.to_sym).nil?
        raise(ArgumentError, "#{self::ERROR_PREFIX} Association '#{ part }' undefined for '#{self}' model")
      end
      class_name = model.reflect_on_association(part.to_sym).class_name
      model      = class_name.constantize
      return class_name if part == relationship.to_s
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
    return [value] if value.blank?
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
        return values.map {|n| n.to_b.nil? ? n : n.to_b}           # | Avoid getting value returned for convertion failure,
      when 'integer'                                          # | to preserve search consistency.
        return values.map {|n| n.to_i.to_s == n ? n.to_i : n} # | ex: 'tre'.to_i == 0 --> the user may want to search for 'tre' not for 0
      when 'float', 'decimal'                                 # |
        return values.map {|n| n.to_f.to_s == n ? n.to_f : n} # |
      when 'datetime'
        return value.to_s.gsub('"','').to_a
      else
        return formatted_value.to_a.fusion(values)
    end
  end
end
