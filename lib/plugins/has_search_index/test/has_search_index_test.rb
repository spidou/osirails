require File.dirname(__FILE__) + '/helper'
require 'lib/activerecord_test_case'

class HasSearchIndexTest < ActiveRecordTestCase #< Test::Unit::TestCase
  fixtures :people, :data_types
  
  def setup
    
    %w(person summer_job favorite_color gender number identity_card relationship familly_relationship people_wish people_dream wish dream dog).each do |file_name|
      load File.dirname(__FILE__) + "/fixtures/#{file_name}.rb" 
    end

    @person = people(:good_person)
    @data_type_sample = data_types(:data_type_sample)
    @data_type_sample.a_datetime = Date.today.to_datetime                                # define +a_datetime+ here to get a datetime without setting utc.
    Person.has_search_index
  end
  
  def teardown
    @person = nil
    
    %w(Person SummerJob FavoriteColor Gender Number IdentityCard Relationship FamillyRelationship PeopleWish PeopleDream Wish Dream Dog).each do |constant|
      Object.send :remove_const, constant.to_sym if Object.const_defined?(constant)
    end
    silence_warnings do
      HasSearchIndex.class_eval {|e| e.const_set('MODELS', [])}                          # clean the models list where the plugin is defined
    end
  end
  
  def test_has_search_index
    # verify that, if the model is added as relationhip and doesn't implement the plugin, it raise an error
    assert_raise(ArgumentError) { Person.has_search_index :only_relationships => [:gender] }
    
    init_plugin_in_all_models
    
    assert_not_nil Person.search_index, "search_index should be defined by the plugin"   
     
    ######################### 
    ### Test attributes (More deep test with private method test below 'test_check_attributes')
    
    attributes_quantity = Person.columns.size-1  # -1 because of foreign_key gender_id
    assert_equal attributes_quantity, Person.search_index[:attributes].size ,"Person should have all his attributes within the plugin"  
     
    Person.has_search_index :only_attributes => [:name]
    assert_equal 1, Person.search_index[:attributes].size ,"Person should have only one attribute within the plugin" 
    
    Person.has_search_index :except_attributes => [:name]
    assert_equal attributes_quantity-1, Person.search_index[:attributes].size ,"Person should have all his attributes, excepted one, within the plugin"
    
    Person.has_search_index :except_attributes => :all
    assert_equal 0, Person.search_index[:attributes].size, "Person should NOT have attributes"
    
    #########################
    ### Test relationships (More deep test with private method test below 'test_check_relationships')
    
    relationships_quantity = Person.reflect_on_all_associations.size
    message  = "Person should have all his relationships within the plugin"
    assert_equal relationships_quantity, Person.search_index[:relationships].size, message
    
    Person.has_search_index :only_relationships => [:gender]
    assert_equal 1, Person.search_index[:relationships].size, "Person should have only one relationship within the plugin"
    
    Person.has_search_index :except_relationships => [:gender]
    message = "Person should have all his relationships, excepted one, within the plugin"
    assert_equal relationships_quantity-1, Person.search_index[:relationships].size, message
    
    Person.has_search_index :except_relationships => :all
    assert_equal 0, Person.search_index[:relationships].size, "Person should NOT have relationships"
    
    #########################
    ### Test additional attributes
    
    assert_equal 0, Person.search_index[:additional_attributes].size ,"Person should NOT have additional attributes within the plugin"
     
    Person.has_search_index :additional_attributes => {:name => :string}
    assert_equal 1, Person.search_index[:additional_attributes].size ,"Person should have only one additional attributes within the plugin"
    
    assert_raise(ArgumentError) { Person.has_search_index :additional_attributes => [:name] }
    
    #########################
    ### Test displayed attributes
    assert_equal 0, Person.search_index[:displayed_attributes].size, "Person should NOT have displayed attributes"
    
    Person.has_search_index :displayed_attributes => [:name]
    assert_equal 1, Person.search_index[:displayed_attributes].size, "Person should have only one displayed attributes"

    assert_raise(ArgumentError) { Person.has_search_index :displayed_attributes => "bad arg" }
  end
  
  # private method called by has_search_index
  def test_check_relationships
    assert_raise(ArgumentError) { Person.has_search_index :except_relationships => 'bad arg' }
    
    assert_raise(ArgumentError) { Person.has_search_index :only_relationships => ['wrong_relationship_name'] } 
    assert_raise(ArgumentError) { Person.has_search_index :only_relationships => 'bad arg' }
    
    assert_raise(ArgumentError) { Person.has_search_index :only_relationships => [:gender], :except_relationships => [:gender] }
  end
  
  # private method called by has_search_index
  def test_check_attributes
    assert_raise(ArgumentError) { Person.has_search_index :except_attributes => 'bad arg' }
    
    assert_raise(ArgumentError) { Person.has_search_index :only_attributes => ['wrong_relationship_name'] } 
    assert_raise(ArgumentError) { Person.has_search_index :only_attributes => 'bad arg' }
    
    assert_raise(ArgumentError) { Person.has_search_index :only_attributes => [:name], :except_attributes => [:name] }
  end
  
  # Test the main search method
  def test_search_with
    Gender.has_search_index
    Person.has_search_index :only_attributes => [:age], :additional_attributes => {:name => :string}
    create_people
    
    # Test undefined relationship
    assert_raise(ArgumentError) { Person.search_with("wrong_relationship.name" => "value") }
    
    # Test undefined attribute
    assert_raise(ArgumentError) { Person.search_with("gender.wrong_attribute" => "value") }
    
    # Test all kind of +search_type+ when mixing +additional_results+ to +database_results+
    message = "Returned collection should contain"
    
    assert_equal 1, Person.search_with('age' => 22, 'name' => 'frank').size,
      "#{message} 1 object with age == 22 AND name like 'frank'"
      
    assert_equal 1, Person.search_with('age' => 22, 'name' => 'frank', :search_type => 'and').size,
      "#{message} 1 object with age == 22 AND name like 'frank'"
      
    assert_equal 2, Person.search_with('age' => 22, 'name' => 'frank', :search_type => 'or').size,
      "#{message} 2 objects with age == 22 OR name like 'frank'"
      
    assert_equal 4, Person.search_with('age' => {:value => 22, :action => '<'}, 'name' => 'frank', :search_type => 'not').size,
      "#{message} 4 objects with age >= 22 AND name not like 'frank'"
  end
  
  def test_search_only_database_attributes
    init_plugin_in_all_models
    Person.has_search_index
    create_people
    message = "Returned objects should be the same"
    
    #########################
    ## Test direct attribute
    
    find_result        = Person.all(:conditions => ['name like?', '%good%']).collect(&:id)
    search_with_result = Person.search_with('name' => 'good').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    #########################
    # Test simple nested attribute
    
    Gender.create(:name => 'femme')
    @person.update_attributes(:gender_id => Gender.first.id)
    find_result        = Person.all(:include => [:gender], :conditions => ['genders.name like?', '%femme%']).collect(&:id)
    search_with_result = Person.search_with('gender.name' => 'femme').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    #########################
    # Test complex nested attribute
    
    NumberType.create(:name => "mobile")
    number = Number.create(:number_type_id => NumberType.first.id)
    friend = Person.create(:name => 'friend')
    friend.numbers  << number
    @person.friends << friend
    find_result        = Person.all(:include => [{:friends => [{:numbers => [:number_type]} ]} ], :conditions => ['number_types.name like?', '%mobile%']).collect(&:id)
    search_with_result = Person.search_with('friends.numbers.number_type.name' => 'mobile').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # That part don't work because of a bug when using eager loading with 'has_one :through' (http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_one#554-has-one-through-belongs-to-not-working)
#    NumberType.create(:name => "fixe")
#    number = Number.create(:number_type_id => NumberType.first.id)
#    love = Person.create(:name => 'bad')
#    love.numbers << number
#    @person.love = love
#    @person.save
#    find_result        = Person.all(:include => [{:love => [{:numbers => [:number_type]} ]} ], :conditions => ['number_types.name like?', '%mobile%']).collect(&:id)
#    search_with_result = Person.search_with('love.numbers.number_type.name' => 'mobile').collect(&:id)
#    
#    assert_equal find_result, search_with_result, message

    #########################
    ## Test with all kind of +values+ formats
    
    # 'value'
    find_result        = Person.all(:conditions => ['name like?', '%good%']).collect(&:id)
    search_with_result = Person.search_with('name' => 'good').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # 'value value2'
    find_result        = Person.all(:conditions => ['(name like? or name like? or name like?)', '%go%','%od%','%go od%']).collect(&:id)
    search_with_result = Person.search_with('name' => 'go od').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # {:value => 'value', ...}
    find_result        = Person.all(:conditions => ['name like?', '%good%']).collect(&:id)
    search_with_result = Person.search_with('name' => 'good').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # {:value => 'value value2', ...}
    find_result        = Person.all(:conditions => ['(name =? or name =? or name =?)', 'go','od','go od']).collect(&:id)
    search_with_result = Person.search_with('name' => {:value => 'go od', :action => "="}).collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # [{:value => 'value', ...}, {:value => 'value', ...}]
    find_result        = Person.all(:conditions => ['(name =?) and (people.name !=?)', 'good', 'bad']).collect(&:id)
    search_with_result = Person.search_with('name' => [{:value => 'good', :action => "="}, {:value => 'bad', :action => "!="}]).collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # [{:value => 'value value2', ...}, {:value => 'value value2', ...}]
    conditions_text    = '(name =? or name =? or name =?) and (name !=? or name !=? or name !=?)'
    find_result        = Person.all(:conditions => [conditions_text, 'go','od','go od','ba','ad','ba ad']).collect(&:id)
    search_with_result = Person.search_with('name' => [{:value => 'go od', :action => "="}, {:value => 'ba ad', :action => "!="}]).collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    #########################
    ## Test with all kind of +search_type+
    values             = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
    # OR
    find_result        = Person.all(:conditions => ['name like? or name like?', '%good%', '%bad%']).collect(&:id)
    search_with_result = Person.search_with('name' => values, :search_type => 'or').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # NOT
    find_result        = Person.all(:conditions => ['name not like? and name not like?', '%good%', '%bad%']).collect(&:id)
    search_with_result = Person.search_with('name' => values, :search_type => 'not').collect(&:id)
    
    assert_equal find_result, search_with_result, message
    
    # AND
    find_result        = Person.all(:conditions => ['name like? and name like?', '%good%', '%bad%']).collect(&:id)
    search_with_result = Person.search_with('name' => values, :search_type => 'and').collect(&:id)
    
    assert_equal find_result, search_with_result, message
  end
  
  def test_search_only_additional_attributes
  
    ## Test with all kind of +search_type+
    Person.has_search_index :additional_attributes => {:name => :string, :age => :integer}
    create_people
    collection = Person.all
    message    = "Returned objects should be the same"
    
    # OR
    additional_result  = collection.select {|n| n.name.downcase.match('good'.downcase) or n.age == 20}.collect(&:id)
    search_with_result = Person.search_with('name' => 'good', 'age' => 20, :search_type => 'or').collect(&:id)
    
    assert_equal additional_result, search_with_result, message
    
    # NOT
    additional_result  = collection.select {|n| n.name != 'good' and n.age != 20}.collect(&:id)
    search_with_result = Person.search_with('name' => {:value => 'good', :action => '='}, 'age' => 20, :search_type => 'not').collect(&:id)
    
    assert_equal additional_result, search_with_result, message
    
    # AND
    additional_result  = collection.select {|n| n.name.downcase.match('good'.downcase) and n.age > 20}.collect(&:id)
    search_with_result = Person.search_with('name' => 'good', 'age' => {:value => 20, :action => ">"}, :search_type => 'and').collect(&:id)
    
    assert_equal additional_result, search_with_result, message
  end
  
  def test_match_regexp
    # test match a word
    data = expression = "string"
    assert Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should match"
    expression += 's'
    assert !Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should NOT match"

    # test match word's end
    expression = "*.txt"
    data = 'string.txt'
    assert Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should match"
    data = 'string.pdf'
    assert !Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should NOT match"

    # test match word's begining
    expression = "test_*"
    data = 'test_string'
    assert Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should match"
    data = 'test.string'
    assert !Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should NOT match"

    # test match word's content
    expression = "*event*"
    data = 'new_event'
    assert Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should match"
    data = 'new_action'
    assert !Person.match_regexp(data, expression), "'#{data}' and '#{expression}' should NOT match"
  end
  
  def test_search_index_attributes
    Person.has_search_index :only_attributes => [:name]
    assert_equal 1, Person.search_index_attributes.size, "search_index_attributes should contain 1 attribute"

    Person.has_search_index :only_attributes => [:name], :additional_attributes => {:name => :string}
    assert_equal 1, Person.search_index_attributes.size,
      "search_index_attributes should contain 1 attribute because the direct and the additional attributes are the same"
    
    Person.has_search_index :only_attributes => [:name], :additional_attributes => {:created_at => :datetime}
    assert_equal 2, Person.search_index_attributes.size, "search_index_attributes should contain 2 attributes"
  end
  
  def test_search_index_attribute_type
    # database attributes types are defined by model definition (based onto database)
    defined_columns = Person.columns.select {|n| Person.search_index_attributes.include?(n)}
    defined_columns.each do |column|
      assert_equal column.type.to_s, Person.search_index_attribute_type(column.name),
        "#{column.name}'s type within the plugin should be as defined into the model"
    end
    
    # additional attributes types are more flexible and can be defined while plugin call into the model
    Person.has_search_index :additional_attributes => {:created_at => :date}
    assert_equal 'date', Person.search_index_attribute_type('created_at'), "created_at's type should be as defined within the plugin call"
  end
  
  def test_is_additional
    assert !Person.is_additional?('name'), "'name' should not be an additional attribute"
    
    Person.has_search_index(:additional_attributes => {:name => :string})
    assert Person.is_additional?('name'), "'name' should be an additional attribute"
    
    # with wrong nested resource
    assert_raise(ArgumentError) { Person.is_additional?('gander.name') }
    
    # with nested resource that don't implement the plugin
    assert_raise(RuntimeError) { Person.is_additional?('gender.name') }
    
    # with nested resource that implement the plugin
    Gender.has_search_index :additional_attributes => {:name => :string}
    assert Person.is_additional?('gender.name'), "'gender.name' should be an additional attribute"
  end
  
  def test_only_additional_attributes
    attributes = {'name' => 'string', 'created_at' => 'datetime'}
    
    Person.has_search_index :additional_attributes => {:name => :string, :created_at => :datetime}
    assert Person.only_additional_attributes?(attributes)
    
    Person.has_search_index :only_attributes => [:name], :additional_attributes => {:created_at => :datetime}
    assert !Person.only_additional_attributes?(attributes)
  end
  
  def test_only_database_attributes
    attributes = {'name' => 'string', 'created_at' => 'datetime'}
    
    Person.has_search_index :only_attributes => [:name, :created_at]
    assert Person.only_database_attributes?(attributes)
    
    Person.has_search_index :only_attributes => [:name], :additional_attributes => {:created_at => :datetime}
    assert !Person.only_database_attributes?(attributes)
  end
  
  def test_get_include_array
    #########################
    ## Simple include
    
    SummerJob.has_search_index :except_relationships => :all
    Person.has_search_index :only_relationships => [:summer_jobs]
    
    expected_array = [:summer_jobs]
    assert_equal expected_array, Person.get_include_array, "include_array should be as expected : #{expected_array.inspect}"
    
    #########################
    ## Nested include
    
    NumberType.has_search_index :except_relationships => :all
    Number.has_search_index :only_relationships => [:number_type]
    Person.has_search_index :only_relationships => [:summer_jobs, :numbers]
    
    expected_array = [:summer_jobs, {:numbers => [:number_type]}]
    assert_equal expected_array, Person.get_include_array, "include_array should be as expected : #{expected_array.inspect}"
  end
  
  def test_filter_include_array_from_prefixes
    #########################
    ## Simple include
    
    SummerJob.has_search_index :except_relationships => :all
    Person.has_search_index :only_relationships => [:summer_jobs]
    include_array  = [:summer_jobs]
    
    expected_array = include_array
    assert_equal expected_array, Person.filter_include_array_from_prefixes(include_array, ['summer_jobs']),
      "include_array should be as expected : #{expected_array.inspect}"
      
    expected_array = []
    assert_equal expected_array, Person.filter_include_array_from_prefixes(include_array, []),
      "include_array should be as expected : #{expected_array.inspect}"
    
    #########################
    ## Nested include
    
    NumberType.has_search_index :except_relationships => :all
    Number.has_search_index :only_relationships => [:number_type]
    Person.has_search_index :only_relationships => [:summer_jobs, :numbers]
    include_array  = [:summer_jobs, {:numbers => [:number_type]}]
    
    expected_array = include_array
    assert_equal expected_array,  Person.filter_include_array_from_prefixes(include_array, ['summer_jobs', 'numbers.number_type']),
      "include_array should be as expected : #{expected_array.inspect}"
      
    expected_array = [:summer_jobs, :numbers]
    assert_equal expected_array,  Person.filter_include_array_from_prefixes(include_array, ['summer_jobs', 'numbers']),
      "include_array should be as expected : #{expected_array.inspect}"
      
    expected_array = []
    assert_equal expected_array, Person.filter_include_array_from_prefixes(include_array, []),
      "include_array should be as expected : #{expected_array.inspect}"
  end
  
  def test_search_match
  
    assert_raise(ArgumentError) {Person.search_match?(@person, 'name', 'good', 'bad search_type')}
    
    #########################
    ## Test with all kind of +values+ formats
    
    # 'value'
    assert Person.search_match?(@person, 'name', 'good', 'or'), "@person's name should match with 'good'"
    assert !Person.search_match?(@person, 'name', 'bad', 'or'), "@person's name shouldn't match with 'bad'"
      
    # 'value value2'
    assert Person.search_match?(@person, 'name', 'gd goo', 'or'), "@person's name should match with 'gd' or 'goo'"
    assert !Person.search_match?(@person, 'name', 'b bad', 'or'), "@person's name shouldn't match with 'b' or 'bad'"
      
    # {:value => 'value', ...}
    assert Person.search_match?(@person, 'name', {:value => 'good', :action => 'like'}, 'or'), "@person's name should match with 'good'"
    assert !Person.search_match?(@person, 'name', {:value => 'bad', :action => 'like'}, 'or'), "@person's name shouldn't match with 'bad'"
      
    # {:value => 'value value2', ...}
    assert Person.search_match?(@person, 'name', {:value => 'gd goo', :action => 'like'}, 'or'), "@person's name should match with 'gd' or 'goo'"
    assert !Person.search_match?(@person, 'name', {:value => 'b bad', :action => 'like'}, 'or'), "@person's name shouldn't match with 'b' or 'bad'"
      
    # [{:value => 'value', ...}, {:value => 'value', ...}]
    assert Person.search_match?(@person, 'name', [{:value => 'good', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'or'),
      "@person's name should match with 'good' or 'another_name'"
    assert !Person.search_match?(@person, 'name', [{:value => 'bad', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'or'),
      "@person's name shouldn't match with 'bad' or 'another_name'"
    
    # [{:value => 'value value2', ...}, {:value => 'value value2', ...}]
    assert Person.search_match?(@person, 'name', [{:value => 'gd goo', :action => 'like'}, {:value => 'another name', :action => 'like'}], 'or'),
      "@person's name should match with ('gd' or 'goo') or ('another' or 'name')"
    assert !Person.search_match?(@person, 'name', [{:value => 'b bad', :action => 'like'}, {:value => 'another name', :action => 'like'}], 'or'),
      "@person's name shouldn't match with ('b' or 'bad') or ('another' or 'name')"
    
    #########################
    ## Test all kind of actions (according to different datatypes)
    
    types = { :string => "good",
              :binary => "0111 0001",
              :text => "lorem ipsum azerty toto",
              :integer => 1,
              :float => 1.2,
              :decimal => 2.345,
              :boolean => true,
              :datetime => Date.today.to_datetime,  # use this to avoid problems with time differences
              :date => Date.today }
              
    DataType.has_search_index :additional_attributes => { :a_string => :string, :a_binary => :binary, :a_text => :text, :a_integer => :integer,
                                                          :a_float => :float, :a_boolean => :boolean, :a_datetime => :datetime,
                                                          :a_date => :date, :a_decimal => :decimal}
                                                          
    types.each_pair do |data, good_value|
      message = "+a_#{data.to_s}+ ( #{@data_type_sample.send("a_#{data.to_s}").to_s.downcase} ) - ( #{good_value.to_s.downcase} )"
      case data
        when :string, :text, :binary
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '='}, 'or'), "data should match #{message}"
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => 'like'}, 'or'), "data should match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '!='}, 'or'), "data should NOT match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => 'not like'}, 'or'), "data should NOT match #{message}"
          
        when :integer,:decimal, :date, :datetime, :float
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '='}, 'or'), "data should match #{message}"
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '>='}, 'or'), "data should match #{message}"
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '<='}, 'or'), "data should match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '!='}, 'or'), "data should NOT match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '<'}, 'or'), "data should NOT match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '>'}, 'or'), "data should NOT match #{message}"
          
        when :boolean
          assert DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '='}, 'or'), "data should match #{message}"
          assert !DataType.search_match?(@data_type_sample, "a_#{data.to_s}", {:value => good_value, :action => '!='}, 'or'), "data should NOT match #{message}"
      end
    end
      
    #########################
    ## Test all kind of +search_type+
    
    assert Person.search_match?(@person, 'name', [{:value => 'good', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'or'),
      "@person's name should match with 'good' or 'another_name'"
      
    assert !Person.search_match?(@person, 'name', [{:value => 'bad', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'or'),
      "@person's name shouldn't match with 'bad' or 'another_name'"
      
    assert !Person.search_match?(@person, 'name', [{:value => 'good', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'and'),
      "@person's name should NOT match with 'good' and 'another_name'"
      
    assert !Person.search_match?(@person, 'name', [{:value => 'bad', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'and'),
      "@person's name shouldn't match with 'bad' and 'another_name'"
      
    assert !Person.search_match?(@person, 'name', [{:value => 'another_name', :action => 'like'}, {:value => 'good', :action => 'like'}], 'not'),
      "@person's name should NOT match with !('good' or 'another_name')"
      
    assert Person.search_match?(@person, 'name', [{:value => 'bad', :action => 'like'}, {:value => 'another_name', :action => 'like'}], 'not'),
      "@person's name should match with !('bad' or 'another_name')"
  end
  
  def test_get_nested_object
    assert_raise(ArgumentError) {Person.get_nested_object(@person, "not an array")}
    
    #########################
    ## Test simple nested_ressource architecture with                |-> one
    
    @person.gender = Gender.new(:name => 'man', :male => true)
    assert_equal @person.gender, Person.get_nested_object(@person, ["gender"]), "the two objects should be equal"
    
    #########################
    ## Test a more complex nested_ressources architecture with       |-> many -> one
    
    fixe   = NumberType.new(:name => 'fixe')
    mobile = NumberType.new(:name => 'mobile')
    5.times do |i|
      number = Number.new(:value => i.to_s)
      number.number_type = fixe
      @person.numbers   += [number]
    end
    4.times do |i|
      number = Number.new(:value => i.to_s)
      number.number_type = mobile
      @person.numbers   += [number]
    end
    assert_equal 9, Person.get_nested_object(@person, ["numbers"]).size, "@person should have 9 numbers"
    assert_equal 2, Person.get_nested_object(@person, ["numbers","number_type"]).size, "@person should have 2 DISTINCT number_types"
  end
  
  def test_search_attributes_format_hash
    message =  "Person's attributes Hash should be as expected"
    
    #########################
    ## Test two configurations with the same expected result
    
    expected_hash = {'name' => "value", 'id' => 'value'}
    
    Person.has_search_index :only_attributes => [:name, :id]
    assert_equal expected_hash, Person.format_attributes_hash_for_simple_search('value'), message
    
    Person.has_search_index :only_attributes => [:name], :additional_attributes => {:id => :integer}
    assert_equal expected_hash, Person.format_attributes_hash_for_simple_search('value'), message
    
    #########################
    ## Test with all attributes 
    
    expected_hash = {"name"=>"value", "created_at"=>"value", "updated_at"=>"value", "id"=>"value", "age"=>"value"}
    Person.has_search_index
    assert_equal expected_hash, Person.format_attributes_hash_for_simple_search('value'), message
  end
  
  
  def test_negative
    positives = ["=",">","<","like"]
    negatives = ["!=","<=",">=","not like"]
    
    positives.each_with_index do |positive, i|
      assert_equal Person.negative(positive), negatives[i], "#{Person.negative(positive)} negative's form should be equal to #{negatives[i]}"
    end
  end
  
  def test_format_date
    message               = "returned date should be as expected"
    params_date           = {'date(0i)' => '30', 'date(1i)' => '12', 'date(2i)' => '1920'}
    params_datetime       = {'date(0i)' => '30', 'date(1i)' => '12', 'date(2i)' => '1920', 'date(3i)' => '23', 'date(4i)' => '59'}
    params_other_data_ype = {'value' => "string with useless space at the end       "}
    
    assert_equal "1920/12/30", Person.format_date(params_date, 'date'), message
    assert_equal "1920/12/30", Person.format_date(params_datetime, 'date'), message
    assert_equal "1920/12/30 23:59:00", Person.format_date(params_datetime, 'datetime'), message
    assert_equal "string with useless space at the end", Person.format_date(params_other_data_ype, 'string'), "String should be stripped"
  end

  #### Privates methods tested directly
  def test_split_value
    message = "Returned value should be as expected"
    DataType.has_search_index
    
    #########################
    ## Test integer
    
    assert_equal [1], DataType.send(:split_value, DataType, 'a_integer', '1'), message
    assert_equal [1, 0, 10], DataType.send(:split_value, DataType, 'a_integer', '1 0 10'), message
    
    #########################
    ## Test boolean
    
    assert_equal [true], DataType.send(:split_value, DataType, 'a_boolean', '1'), message
    assert_equal [true, false, false], DataType.send(:split_value, DataType, 'a_boolean', '1 0 false'), message
    
    #########################
    ## Test float
    
    assert_equal [1.2], DataType.send(:split_value, DataType, 'a_float', '1.2'), message
    assert_equal [1.2, 0.45, 123.203], DataType.send(:split_value, DataType, 'a_float', '1.2 0.45 123.203'), message
    
    #########################
    ## Test decimal
    
    assert_equal [1000.2], DataType.send(:split_value, DataType, 'a_decimal', '1000.2'), message
    assert_equal [15.2, 0.45, 13.2], DataType.send(:split_value, DataType, 'a_decimal', '15.2 0.45 13.2'), message
    
    #########################
    ## Test datetime
    
    assert_equal ['2009/9/30 9:43:00'], DataType.send(:split_value, DataType, 'a_datetime', '2009/9/30 9:43:00'), message
    assert_equal ['2009/9/30 9:43:00'], DataType.send(:split_value, DataType, 'a_datetime', '"2009/9/30 9:43:00"'), message
    
    #########################
    ## Test string, text, ...
    
    assert_equal ['john'], DataType.send(:split_value, DataType, 'a_string', 'john'), message
    assert_equal ['john', 'j', 'n', 'john j n'].sort, DataType.send(:split_value, DataType, 'a_string', 'john j n').sort, message
    
    # Test skipping splitting (it's the same thing with string)
    assert_equal ['john is gone'], DataType.send(:split_value, DataType, 'a_text', '"john is gone"'), message
    assert_equal ['john is gone', 'j', 'n', 'john is gone j n'].sort,
                 DataType.send(:split_value, DataType, 'a_text', '"john is gone" j n').sort, message
    
    # Test escaping escape caractere (\) (it's the same thing with text)
    assert_equal ['john is "whoo"'], DataType.send(:split_value, DataType, 'a_string', '"john is \"whoo\""'), message
    assert_equal ['john is "whoo"', 'j', 'n', 'john is "whoo" j n'].sort,
                 DataType.send(:split_value, DataType, 'a_string', '"john is \"whoo\"" j n').sort,  message
    
    # Test adding a special caracter alone
    assert_raise(ArgumentError) {DataType.send(:split_value, DataType, 'a_string', 'some text " string')}
  end
      
  def test_check_relationships_options
    init_plugin_in_all_models
    
    #########################    
    ## Test with :belongs_to :macro
    
    options_before = Person.reflect_on_association(:gender).options
    Person.send(:check_relationships_options, [:gender])
    assert_equal options_before, Person.reflect_on_association(:gender).options, "Options should NOT be different because :macro is :belongs_to"
    
    #########################
    ## Test with no options in (:order, :group, :limit)
    
    options_before = Person.reflect_on_association(:relationships).options
    message        = "Options should NOT be different because there's no options in (:order, :group, :limit)"
    Person.send(:check_relationships_options, [:relationships])
    assert_equal options_before, Person.reflect_on_association(:relationships).options, message
    
    #########################
    ## Test with options in (:order, :group, :limit)
    
    create_summer_jobs(@person.id)
    create_dogs(@person.id)
    message1 = "Conditions should have been generated properly"
    message2 = "Collection should be the same as before the association modification"
    
    ## test :order with a 'to_many' association
    Person.reflect_on_association(:summer_jobs).options[:order] = 'created_at DESC'
    Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
    summer_jobs_ids = Person.first.summer_jobs.collect(&:id)
    Person.has_search_index                                                              # Call the plugin to modify the association's conditions according to options
    
    assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions], message1
    assert_equal summer_jobs_ids, Person.first.summer_jobs.collect(&:id), message2
    
    ## test :order with a 'to_one' association
    Person.reflect_on_association(:dog).options[:order] = 'created_at DESC'
    Person.reflect_on_association(:dog).options[:conditions] = nil
    dog_id = Person.first.dog.id
    Person.has_search_index                                                              # Call the plugin to modify the association's conditions according to options
    
    assert_not_nil Person.reflect_on_association(:dog).options[:conditions], message1
    assert_equal dog_id, Person.first.dog.id, message2
    
    ## test :group
    Person.reflect_on_association(:summer_jobs).options[:group] = 'summer_jobs.salary'
    Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
    summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
    Person.has_search_index                                                              # Call the plugin to modify the association's conditions according to options
    
    assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions], message1
    assert_equal summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort, message2

    ## test :limit without :offset
    Person.reflect_on_association(:summer_jobs).options[:limit] = 2
    Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
    
    assert_raise(ArgumentError) {Person.has_search_index}                                # these to lines are here to verify the raise according to the mysql bug
    Person.reflect_on_association(:summer_jobs).options[:limit] = nil                    #
    
# FIXME uncomment that part when the bug with mysql subqueries will be fixed (http://dev.mysql.com/doc/refman/5.0/en/subquery-errors.html)
#    summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
#    Person.has_search_index                                                              # Call the plugin to modify the association's conditions according to options
#    
#    assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions], message1
#    assert_equal summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort, message2
    
    ## test :limit with :offset
    Person.reflect_on_association(:summer_jobs).options[:limit] = 3
    Person.reflect_on_association(:summer_jobs).options[:offset] = 1
    Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
    
    assert_raise(ArgumentError) {Person.has_search_index}                                # these to lines are here to verify the raise according to the mysql bug
    Person.reflect_on_association(:summer_jobs).options[:limit] = nil                    #
    
# FIXME uncomment that part when the bug with mysql subqueries will be fixed (http://dev.mysql.com/doc/refman/5.0/en/subquery-errors.html)
#    summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
#    Person.has_search_index                                                              # Call the plugin to modify the association's conditions according to options
#
#    assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions], message1
#    assert_equal summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort, message2

    #########################
    ## Test main kind of relationships
    message = "Subquery into association's conditions should be as expected"
    
    # 1-N
    prepare_association(Person, :summer_jobs)
    expected_conditions  = "`summer_jobs`.id in (SELECT `summer_jobs`.id FROM `summer_jobs`"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `summer_jobs`.person_id"
    expected_conditions += " ORDER BY `summer_jobs`.created_at DESC)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:summer_jobs).options[:conditions].first, message
    
    # 1-N :polymorphic
    prepare_association(Person, :numbers)
    expected_conditions  = "`numbers`.id in (SELECT `numbers`.id FROM `numbers`"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `numbers`.has_number_id"
    expected_conditions += " WHERE (`numbers`.has_number_type = 'Person') ORDER BY `numbers`.created_at DESC)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:numbers).options[:conditions].first, message
    
    # 1-1
    prepare_association(Person, :dog)
    expected_conditions  = "`dogs`.id = (SELECT `dogs`.id FROM `dogs`"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `dogs`.person_id"
    expected_conditions += " ORDER BY `dogs`.created_at DESC LIMIT 1)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:dog).options[:conditions].first, message
    
    # 1-1 :polymorphic
    prepare_association(Person, :identity_card)
    expected_conditions  = "`identity_cards`.id = (SELECT `identity_cards`.id FROM `identity_cards`"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `identity_cards`.has_identity_card_id"
    expected_conditions += " WHERE (`identity_cards`.has_identity_card_type = 'Person') ORDER BY `identity_cards`.created_at DESC LIMIT 1)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:identity_card).options[:conditions].first, message
    
    # 1-1 :through
    prepare_association(Person, :love)
    expected_conditions  = "`people`.id = (SELECT `people`.id FROM `people`"
    expected_conditions += " INNER JOIN `familly_relationships` ON `people`.id = `familly_relationships`.love_id"
    expected_conditions += " LEFT OUTER JOIN `people` love_people ON love_people.id = `familly_relationships`.person_id"
    expected_conditions += " ORDER BY `people`.created_at DESC LIMIT 1)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:love).options[:conditions].first, message
    
    # 1-1 :through, :polymorphic
    prepare_association(Person, :dream)
    expected_conditions  = "`dreams`.id = (SELECT `dreams`.id FROM `dreams`"
    expected_conditions += " INNER JOIN `people_dreams` ON `dreams`.id = `people_dreams`.dream_id"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `people_dreams`.has_dream_id"
    expected_conditions += " WHERE (`people_dreams`.has_dream_type = 'Person') ORDER BY `dreams`.created_at DESC LIMIT 1)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:dream).options[:conditions].first, message
    
    # N-N
    prepare_association(Person, :favorite_colors)
    expected_conditions  = "`favorite_colors`.id in (SELECT `favorite_colors`.id FROM `favorite_colors`"
    expected_conditions += " INNER JOIN `favorite_colors_people` ON `favorite_colors`.id = `favorite_colors_people`.favorite_color_id"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `favorite_colors_people`.person_id"
    expected_conditions += " ORDER BY `favorite_colors`.created_at DESC)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:favorite_colors).options[:conditions].first, message
    
    # N-N :through
    prepare_association(Person, :friends)
    expected_conditions  = "`people`.id in (SELECT `people`.id FROM `people`"
    expected_conditions += " INNER JOIN `relationships` ON `people`.id = `relationships`.friend_id"
    expected_conditions += " LEFT OUTER JOIN `people` friends_people ON friends_people.id = `relationships`.person_id"
    expected_conditions += " ORDER BY `people`.created_at DESC)"
    Person.has_search_index
        
    assert_equal expected_conditions, Person.reflect_on_association(:friends).options[:conditions].first, message
    
    # N-N :through, :polymorphic
    prepare_association(Person, :wishes)
    expected_conditions  = "`wishes`.id in (SELECT `wishes`.id FROM `wishes`"
    expected_conditions += " INNER JOIN `people_wishes` ON `wishes`.id = `people_wishes`.wish_id"
    expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `people_wishes`.has_wishes_id"
    expected_conditions += " WHERE (`people_wishes`.has_wishes_type = 'Person') ORDER BY `wishes`.created_at DESC)"
    Person.has_search_index
    
    assert_equal expected_conditions, Person.reflect_on_association(:wishes).options[:conditions].first, message
  end
  
  def test_get_conditions_array_for_criterion
    #########################
    ## Test all kind of +value+ formats
    
    message = "Conditions array should be as expected"
    
    # 'value'
    expected_array = ["(people.name like?)", '%value%']
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion ,Person, 'value', 'people.name', 'or'), message
    
    # 'value value2'
    expected_array = ["(people.name like? or people.name like? or people.name like?)", '%value%', '%value2%', '%value value2%']
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion ,Person, 'value value2', 'people.name', 'or'), message
    
    # {:value => 'value', ...}
    expected_array = ["(people.name like?)", '%value%']
    value          = {:value => 'value', :action => 'like'}
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'or'), message
    
    # {:value => 'value value2', ...}
    expected_array = ["(people.name like? or people.name like? or people.name like?)", '%value%', '%value2%', '%value value2%']
    value          = {:value => 'value value2', :action => 'like'}
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'or'), message
    
    # [{:value => 'value', ...}, {:value => 'value', ...}]
    expected_array = ["(people.name like?) or (people.name like?)", '%value%', '%value2%']
    value          = [{:value => 'value', :action => 'like'}, {:value => 'value2', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'or'), message
      
    # [{:value => 'value value2', ...}, {:value => 'value value2', ...}]
    expected_array = ["(people.name like? or people.name like? or people.name like?) or (people.name like? or people.name like? or people.name like?)",
                      '%value%', '%value2%', '%value value2%',
                      '%value3%', '%value4%', '%value3 value4%']
    value          = [{:value => 'value value2', :action => 'like'}, {:value => 'value3 value4', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'or'), message
      
    #########################
    ## Test all kind of +search_type+
    
    # OR
    # tested above
    
    # AND
    # [{:value => 'value', ...}, {:value => 'value', ...}]
    expected_array = ["(people.name like?) and (people.name like?)", '%value%', '%value2%']
    value          = [{:value => 'value', :action => 'like'}, {:value => 'value2', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'and'), message
      
    # [{:value => 'value value2', ...}, {:value => 'value value2', ...}]
    conditions_text  = "(people.name like? or people.name like? or people.name like?) and (people.name like? or people.name like? or people.name like?)"
    expected_array   = [conditions_text, '%value%', '%value2%', '%value value2%', '%value3%', '%value4%', '%value3 value4%']
    value            = [{:value => 'value value2', :action => 'like'}, {:value => 'value3 value4', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'and'), message
    
    # NOT
    # [{:value => 'value', ...}, {:value => 'value', ...}]
    expected_array = ["(people.name not like?) and (people.name not like?)", '%value%', '%value2%']
    value          = [{:value => 'value', :action => 'like'}, {:value => 'value2', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'not'), message
      
    # [{:value => 'value value2', ...}, {:value => 'value value2', ...}]
    conditions_text  = "(people.name not like? and people.name not like? and people.name not like?) and"
    conditions_text += " (people.name not like? and people.name not like? and people.name not like?)"
    expected_array   = [conditions_text, '%value%', '%value2%', '%value value2%', '%value3%', '%value4%', '%value3 value4%']
    value            = [{:value => 'value value2', :action => 'like'}, {:value => 'value3 value4', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'not'), message
    
    #########################
    ## Test when passing a conditions_array to be completed
    
    array_to_be_conpleted = ["(people.id =?)",'1']
    completed_array       = ["(people.id =?) or (people.name like?) or (people.name like?)", '1', '%value%', '%value2%']
    value                 = [{:value => 'value', :action => 'like'}, {:value => 'value2', :action => 'like'}]
    assert_equal completed_array, Person.send(:get_conditions_array_for_criterion, Person, value, 'people.name', 'or', array_to_be_conpleted), message
    
    #########################
    ## Test with nested resource
    
    Gender.has_search_index
    expected_array = ["(genders.name like?) and (genders.name like?)", '%name1%', '%name2%']
    value          = [{:value => 'name1', :action => 'like'}, {:value => 'name2', :action => 'like'}]
    assert_equal expected_array, Person.send(:get_conditions_array_for_criterion, Gender, value, 'genders.name', 'and'), message
  end
  
  def test_generate_attribute_prefix
    message       = 'prefix should be as expected'
    
    #########################
    ## Test no redundancy
    include_array = [{:dog => [{:numbers => [:number_type]} ]} ]
    
    path          = 'people.dog.numbers.number_type'
    assert_equal 'number_types', Person.send(:generate_attribute_prefix, path, include_array), message
    
    #########################
    ## Test 1 redundancy
    include_array = [{:dog => [{:numbers => [:number_type]} ]},
                     {:numbers => [:number_type]} ]
    
    path          = 'people.dog.numbers.number_type'
    assert_equal 'number_types', Person.send(:generate_attribute_prefix, path, include_array), message
    
    path          = 'people.numbers.number_type'
    assert_equal 'number_types_numbers', Person.send(:generate_attribute_prefix, path, include_array), message
    
    #########################
    ## Test 2 redundancy
    include_array = [{:love => [{:dog => [{:numbers => [:number_type]} ]} ]},
                     {:dog => [{:numbers => [:number_type]} ]},
                     {:numbers => [:number_type]} ]
    
    path          = 'people.love.dog.numbers.number_type'
    assert_equal 'number_types', Person.send(:generate_attribute_prefix, path, include_array), message
    
    path          = 'people.dog.numbers.number_type'
    assert_equal 'number_types_numbers', Person.send(:generate_attribute_prefix, path, include_array), message
    
    path          = 'people.numbers.number_type'
    assert_equal 'number_types_numbers_2', Person.send(:generate_attribute_prefix, path, include_array), message
  end
  
  def test_get_prefix_order
    message = "Returned prefix_table should be as expected"
    
    include_array = [{:sub_model => [:model]}, {:numbers => [:number_type, {:sub_model => [:model]} ]} ]
    expected_prefix_table = ["people.sub_model", "people.numbers.sub_model"]
    assert_equal expected_prefix_table, Person.send(:get_prefix_order, 'people', include_array, 'sub_model', 'model'), message
    
    include_array = [{:numbers => [:number_type, {:sub_model => [:model]} ]}, {:sub_model => [:model]}]
    expected_prefix_table = ["people.numbers.sub_model", "people.sub_model"]
    assert_equal expected_prefix_table, Person.send(:get_prefix_order, 'people', include_array, 'sub_model', 'model'), message
  end
  
  def test_relationship_class_name
    [Number, NumberType].each do |model|
      model.has_search_index
    end
    Person.has_search_index
    message = "Returned model should be as expected"
    path    = 'people.love.numbers.number_type'
    
    assert_equal 'Person', Person.send(:relationship_class_name, path, 'love'), message
    assert_equal 'Number', Person.send(:relationship_class_name, path, 'numbers'), message
    assert_equal 'NumberType', Person.send(:relationship_class_name, path, 'number_type'), message
  end
  
  private
  
    def init_plugin_in_all_models
      # define the plugin into all models to get full relationships by default into +Person+
      [SummerJob, FavoriteColor, Gender, NumberType, Number, IdentityCard, Relationship,
      FamillyRelationship, PeopleWish, PeopleDream, Wish, Dream, Dog].each do |model|  
        model.has_search_index
      end
    end
    
    def create_people
      {'frank' => 22,'leia'=> 22, 'lilly' => 23, 'joe' => 24, 'jill' => 25}.each do |name, age|
        Person.new(:name => name, :age => age).save
      end
    end
    
    def create_summer_jobs(person_id)
      {:job1 => 100, :job2 => 200, :job3 => 300, :job4 => 200, :job5 => 300, :job6 => 600}.each do |name, salary|
        SummerJob.new(:name => name, :salary => salary, :person_id => person_id).save
      end
    end
    
    def create_dogs(person_id)
      ["dog allemand", "berger allemand", "dog allemand", "pitbull", "dog allemand"].each do |race|
        Dog.new(:person_id => person_id, :race => race).save
      end
    end
    
    def prepare_association(model, association)
      model.reflect_on_association(association).options[:order] = 'created_at DESC'
      model.reflect_on_association(association).options.delete(:group)
      model.reflect_on_association(association).options.delete(:limit)
      model.reflect_on_association(association).options.delete(:conditions)
    end
end
