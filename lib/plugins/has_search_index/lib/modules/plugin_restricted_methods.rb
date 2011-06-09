module RestrictedMethods
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
  #     Employee.search_with("job_contract.start_date" => "1900-2-2")
  #     => nothing because the date is to old, there's no user that have a job_contract's start_date equal to that one
  #
  #    # another example with 'not' +search_type+ to see that it invert +actions+ into +values+:
  #
  #     Employee.search_with("job_contract.start_date" =>{:value => "1900-2-2", :action => ">"}, :search_type => 'not')
  #     => discard all employees with job_contractOrder.search_with("id" => 2) start_date greater than 1900-2-2
  #
  #    # Customer has_many :establishments, and Establishment has_one :address :
  #
  #     Customer.search_with("establishments.address.zip_code" => 97438)
  #     => return all customers that have at least one establishment with zip code equal to '97438'
  #
  #    NB : Date     format => "%Y%m%d"
  #         DateTime format => "%Y%m%d %H:%M"
  #
  def search_with(args={})
    criteria    = args.is_a?(Hash) ? args : get_criteria_for_simple_search(args)
    order       = get_valid_order_clause(criteria.delete(:order))
    group       = get_valid_group_clause(criteria.delete(:group))
    search_type = get_valid_search_type(criteria.delete(:search_type))
    quick       = get_valid_criteria_from_quick_search(criteria.delete(:quick))
    
    check_criteria(quick)
    check_criteria(criteria)
    
    result = []
    if only_database_attributes?(criteria.merge(quick))                            # use only one sql query if there's not additional attributes
      result = search_with_database_attributes(criteria, search_type, order, group, quick)
    else
      result = link_results(                                                       # manage search from normal attributes
        search_with_database_attributes(criteria, search_type, order, group, {}),
        search_with_additional_attributes(criteria, search_type),
        search_type,
        criteria
      )
      
      result &= link_results(                                                      # manage search from quick attributes
        search_with_database_attributes({}, search_type, order, group, quick),
        search_with_additional_attributes(quick, 'or'),
        'or',
        quick
      ) if quick.any?
    end
    
    ## manage the group and order by code because the additional attributes cannot be used into sql
    result = group_and_order(result, order, group) if (order + group).select {|n| is_additional?(HasSearchIndex.get_order_attribute(n)) }.any?
    return result
  end
  
  # Method to check search_with attributes
  #
  def check_criteria(criteria)
    return nil unless criteria && criteria.is_a?(Hash) && !criteria.empty?
    criteria.each do |a, v|
      check_criterion_attribute(a.to_s.downcase)
      check_criterion_values(v)
    end
    
    criteria
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
    self.search_index_relationships.each do |relationship|
      model = self.reflect_on_association(relationship).class_name
      unless ignore.include?("#{model.to_s}") 
        ignore_copy = ignore.fusion(["#{self.to_s}"])
        model       = reflect_relationship(relationship)
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
  
  # Method to check relationship's plugin implementation
  # Return the model corresponding to the relationship,
  #  after testing if the explicit configured relationships (configured with :only_relationships) implement the plugin.
  # Return nil if the model doesn't implement the plugin and is not configured explicitly.
  #
  def reflect_relationship(relationship, check_implicit = false)
    class_name         = search_index_relationship_class_name("#{ self.table_name }.#{ relationship }", relationship)
    model              = class_name.constantize
    need_to_be_checked = (check_implicit ? true : self.search_index[:only_relationships].include?(relationship.to_sym) )
    unless HasSearchIndex::MODELS.include?(class_name)
      message = "#{self::ERROR_PREFIX} Association '#{ relationship }' needs the '#{ class_name }' model to implement has_search_index plugin"
      need_to_be_checked ? raise(ArgumentError, message) : (model = nil)
    end
    model
  end
  
  # Method to permit model retrievement from a +relationship+
  # according to a +path+ ex :
  # # => Employee.search_index_relationship_class_name("employees.numbers.number_type", "numbers") -> 'Number'
  #
  # # => Employee.search_index_relationship_class_name("employees.numbers.number_type", "employees") -> 'Employee'
  #
  # # => Employee.search_index_relationship_class_name("employees.numbers.number_type", :employees) -> 'Employee'
  #
  # the +path+ must begin by main model table_name (Employee -> 'employees') or a direct relationship (Employee has_many :numbers --> 'numbers')
  #
  def search_index_relationship_class_name(path, relationship = nil)
    relationship_class_name_from(path, relationship)
  end
  
  # Method to return all USABLE relationships and
  # raise an error if a mandatory relationship (define with :only_relationships) does not implement the plugin
  #
  def search_index_relationships
    relationships = []
    self.search_index[:relationships].each do |relationship|
      model = reflect_relationship(relationship).to_s
      relationships << relationship if HasSearchIndex::MODELS.include?(model)
    end
    return relationships
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
end
