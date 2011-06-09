require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HasSearchIndexTest < ActiveRecordTestCase
  
  context "" do # context to keep clean Models between each tests
    setup do
      %w(person summer_job favorite_color gender number identity_card relationship familly_relationship people_wish people_dream wish dream dog).each do |file_name|
        load "fixtures/#{file_name}.rb" 
      end
    end
    
    teardown do
      %w(Person SummerJob FavoriteColor Gender Number IdentityCard Relationship FamillyRelationship PeopleWish PeopleDream Wish Dream Dog).each do |constant|
        Object.send :remove_const, constant.to_sym if Object.const_defined?(constant)
      end
      silence_warnings do
        HasSearchIndex.class_eval {|e| e.const_set('MODELS', [])}                          # clean the models list where the plugin is defined
      end
    end
    
    ############################################################
    ### Plugin's integrated search configuration with yaml files
    ############################################################
    context "A Yaml configuration file" do
      setup do
        NumberType.has_search_index :only_attributes => [:name]
        Number.has_search_index :only_relationships => [:number_type], :only_attributes => [:value, :id]
        Person.has_search_index :only_relationships => [:numbers], :only_attributes => [:name, :age]
        
        
        @yml_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'person.yml')
        @options = {'person' => {'columns' => ['name'],
                                 'order' => [],
                                 'per_page' => [],
                                 'group' => [],
                                 'filters' => [] }}
        @expected = {:default_query => nil,
                     :columns => ['name', 'age'],
                     :order => ['name'],
                     :per_page => [10, 20],
                     :group => ['age'],
                     :filters => ['name', 'age', {'phone_number' => 'numbers.value'}, {'phone_type' => 'numbers.number_type.name'}],
                     :model => 'Person',
                     :quick_search => []}
      end
      
      teardown do
        @yml_path = @options = @expected = nil
        HasSearchIndex::HTML_PAGES_OPTIONS[:person] = nil
      end
      
      context "wich is well named and with a valid path" do
        setup do
          HasSearchIndex.load_page_options_from(@yml_path)
        end
        
        should "return expected result without error" do
          assert_nothing_raised do
            assert_equal(@expected, HasSearchIndex::HTML_PAGES_OPTIONS[:person])
          end
        end
      end
      
      context "wich is not named as a valid model" do
        setup do
          @yaml_path = "some_path/toto.yml"
        end
        
        should "raise a ArgumentError" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yaml_path)}
        end
      end
      
      context "wich has not a valid path" do
        setup do
          @yaml_path = "invalid_path_path/person.yml"
        end
        
        should "raise a Errno::ENOENT" do
          assert_raise(Errno::ENOENT) { HasSearchIndex.load_page_options_from(@yaml_path)}
        end
      end
      
      context "wich is named as a valid model not implementing 'has_search_index'" do
        setup do
          @yaml_path = "some_path/summer_job.yml"
        end
        
        should "raise a ArgumentError" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yaml_path, @options)}
        end
      end
      
      context "without mandatory OPTION (:columns)" do
        setup do
          @options['person'].delete('columns')
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      context "with any OPTION that is not an Array" do
        setup do
          @options['person']['group'] = "Bad OPTION type"
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      [:group, :order].each do |option|
        context "with :#{ option } OPTION that contains *to_many* relationship for the plugin" do
          setup do
            Person.has_search_index :only_relationships => [:summer_jobs]
            SummerJob.has_search_index :only_attributes => [:id]
            @options['person'][option.to_s] = ['summer_jobs.id']
          end
          
          should 'raise an ArgumentError' do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options) }
          end
        end
      end
      
      [:filters, :columns, :quick_search].each do |option|
        context "with :#{ option } OPTION that contains a *to_many* relationship for the plugin" do
          setup do
            Person.has_search_index :only_relationships => [:summer_jobs]
            SummerJob.has_search_index
            @options['person'][option.to_s] = ['summer_jobs.id']
          end
          
          should 'raise nothing' do
            assert_nothing_raised { HasSearchIndex.load_page_options_from(@yml_path, @options)}
          end
        end
      end
      
      context "with any ATTRIBUTE_PATH in :columns that contains undefined attribute for the model" do
        setup do
          @options['person']['columns'] = ['undefined_attribute']
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
        
      context "with any ATTRIBUTE_PATH in :columns that contains undefined relationship for the model" do
        setup do
          @options['person']['columns'] = ['undefined_relationship.id']
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
        
      [:order, :group, :filters].each do |option|
        context "with any ATTRIBUTE_PATH in :#{ option } that contains undefined attribute for the model" do
          setup do
            @options['person'][option.to_s] = ['undefined_attribute']
          end
          
          should 'raise an ArgumentError' do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
          end
        end
        
        context "with any ATTRIBUTE_PATH in :#{ option } that contains undefined attribute for the plugin" do
          setup do
            Person.has_search_index :except_attributes => [:id]
            @options['person'][option.to_s] = ['id']
          end
          
          should 'raise an ArgumentError' do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
          end
        end
        
        context "with any ATTRIBUTE_PATH in :#{ option } that contains undefined relationship for the model" do
          setup do
            @options['person'][option.to_s] = ['undefined_relationship.id']
          end
          
          should 'raise an ArgumentError' do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
          end
        end
        
        context "with any ATTRIBUTE_PATH in :#{ option } that contains undefined relationship for the plugin" do
          setup do
            Person.has_search_index :except_relationships => [:dog]
            @options['person'][option.to_s] = ['dog.id']
          end
          
          should 'raise an ArgumentError' do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
          end
        end
      end
      
      context "with any ATTRIBUTE_PATH, (for :filters OPTION), using both 'alias' and 'globbing' feature" do
        setup do
          @options['person']['filters'] = [{'alias' => "numbers.*"}]
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      context "with any ATTRIBUTE_PATH, (for :filters OPTION), containing value with and without 'alias'" do
        setup do
          @options['person']['filters'] = [{'alias' => "numbers.id"}, 'numbers.id']
          HasSearchIndex.load_page_options_from(@yml_path, @options)
          @expected = [{'alias' => "numbers.id"}]
        end
        
        should 'keep only value with alias configuration' do
          assert_equal(@expected, HasSearchIndex::HTML_PAGES_OPTIONS[:person][:filters])
        end
      end
      
      context "with a default query containing an invalid option" do
        setup do
          @options['person']['default_query'] = {'group' => {}}
        end
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      context "with a default query containing wrong :order option" do
        setup do
          @options['person']['default_query'] ={ 'order' => ['id:Not Desc']}
        end
        
        should 'raise an ArgumentError' do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      context "with a default query containing a criterion that do not respect has_search_index implementation" do
        setup do
          Person.has_search_index :except_attributes => [:name]
          @options['person']['default_query'] = {'criteria' => {:name => 'Name'}}
        end
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options)}
        end
      end
      
      [:group, :columns].each do |option|
        context "with default_query:#{ option } OPTION that do not match :#{ option } OPTION" do
          setup do
            Person.has_search_index :only_relationships => [:summer_jobs]
            SummerJob.has_search_index
            @options['person'][option.to_s] = []
            @options['person']['default_query'] = {option.to_s  => ['summer_jobs.id']}
          end
          
          should "raise Argument Error" do
            assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options) }
          end
        end
      end
      
      context "with default_query:order OPTION that do not match :order OPTION" do
        setup do
          Person.has_search_index :only_relationships => [:summer_jobs]
          SummerJob.has_search_index
          @options['person']['order'] = []
          @options['person']['default_query'] = { 'order' => ['summer_jobs.id:DESC']}
        end
        
        should "raise Argument Error" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options) }
        end
      end
      
      context "with default_query:per_page OPTION that do not match :per_page OPTION" do
        setup do
          @options['person']['per_page'] = [10,20,30]
          @options['person']['default_query'] = {'per_page' => 25}
        end
        
        should "raise Argument Error" do
          assert_raise(ArgumentError) { HasSearchIndex.load_page_options_from(@yml_path, @options) }
        end
      end
    end
    ####################################################
    ### Plugin Implementation into an ActiveRecord Model
    ####################################################
    context "+Person+ implementing the plugin (with many nested resources implementing the plugin)" do
      setup do
        Person.has_search_index
        @person = Person.create(:name => 'good', :age => '20')
        create_summer_jobs(@person.id)
        create_dogs(@person.id)
      end
      
      should "have an instance variable and be included in has_search_index's models" do
        assert Person.respond_to?(:search_index) && HasSearchIndex::MODELS.include?('Person')
      end
      
      should "have search_index_attributes" do
        assert_not_nil Person.search_index_attributes
      end
      
      should "have search_index_relationships" do
        assert_not_nil Person.search_index_relationships
      end
      
      context "with implicit attributes definition" do
        setup do
          @attributes_quantity = Person.columns.size-1  # -1 because of foreign_key gender_id
        end

        should "have all his attributes defined for the plugin" do
          assert_equal @attributes_quantity, Person.search_index[:attributes].size
        end
      end

      context "with valid :only_attributes" do
        setup do
          Person.has_search_index :only_attributes => [:name]
          @model_column = Person.columns.detect {|n| n.name == 'name'}
        end

        should "have only these attributes defined for the plugin" do
          assert_equal 1, Person.search_index[:attributes].size
        end
        
        should "store it into search_index_attributes" do
          assert Person.search_index_attributes.keys.include?('name')
        end
        
        should "have search_index_attribute_type as defined into the model" do
          assert_equal @model_column.type.to_s, Person.search_index_attribute_type('name')
        end
      end

      context "with :only_attributes that is not an Array" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_attributes => 'bad arg' }
        end
      end

      context "with :only_attributes that contain undefined attributes" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_attributes => ['wrong_relationship_name'] }
        end
      end

      context "with valid :except_attributes" do
        setup do
          Person.has_search_index :except_attributes => [:name]
          @attributes_quantity = Person.columns.size-1  # -1 because of foreign_key gender_id
        end

        should "have all his attributes for the plugin, except the excepted ones, defined for the plugin" do
          assert_equal @attributes_quantity-1, Person.search_index[:attributes].size
        end
      end

      context "with :except_attributes that is not an Array" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_attributes => [:name], :except_attributes => [:name] }
        end
      end

      context "with :except_attributes is set to :all" do
        setup do
          Person.has_search_index :except_attributes => :all
        end

        should "not have attribute defined for the plugin" do
          assert_equal 0, Person.search_index[:attributes].size
        end
      end

      context "with :only_attributes and :except_attributes both set" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :except_attributes => 'bad arg' }
        end
      end

      context "with implicit relationships definition" do
        setup do
          @relationships_quantity = Person.reflect_on_all_associations.select {|assoc| [nil,false].include?(assoc.options[:polymorphic])}.size
          @expected_include_array = [:friends, :love] # auto_reference (:friends & :love => class_name == Person)
        end

        should "have all his relationships excepted these which point to polymorphic entity, defined for the plugin" do
          assert_equal @relationships_quantity, Person.search_index[:relationships].size
        end
        
        should "have include_array as expected" do
          assert (@expected_include_array | Person.get_include_array).size == 2  ## compare content without taking in account order
        end
        
        context "for relationship that implements the plugin" do
        
          should "return relationship's class_name without error" do
            assert_nothing_raised { assert_equal Person, Person.reflect_relationship(:friends)} 
          end
        end
        
        context "for relationship that doesn't implement the plugin" do
        
          should "raise an ArgumentError while checking implicit" do
            assert_raise(ArgumentError) { Person.reflect_relationship(:gender, check_implicit = true) }
          end
          
          should "not raise an ArgumentError while skipping implicit" do
            assert_nothing_raised { assert_nil Person.reflect_relationship(:gender)}
          end
        end
      end

      context "with defined :only_relationships" do
        setup do
          Gender.has_search_index
          Person.has_search_index :only_relationships => [:gender]
          @expected_include_array = [:gender]
        end

        should "have only these relationships defined for the plugin" do
          assert_equal 1, Person.search_index[:relationships].size
        end
        
        should "store it into search_index_relationships" do
          assert Person.search_index_relationships.include?(:gender)
        end
        
        should "have include_array as expected" do
          assert_equal @expected_include_array, Person.get_include_array
        end
        
        should "return the relationship's class_name without error" do
          assert_nothing_raised { assert_equal Gender, Person.reflect_relationship(:gender) }
        end
      end

      context "with undefined :only_relationships for the model" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_relationships => [:wrong_relationship_name] }
        end
      end
      
      context "with undefined :only_relationships for the plugin" do
        setup do
          Person.has_search_index :only_relationships => [:gender]
        end
        
        should "not store it into search_index_relationships and raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_index_relationships }
        end
        
        should "not reflect_relationship and raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.reflect_relationship(:summer_job)}
        end
      end

      context "with :only_relationships that is not an Array" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_relationships => 'bad arg' }
        end
      end

      context "with valid :except_relationships" do
        setup do
          Person.has_search_index :except_relationships => [:gender]
          @relationships_quantity = Person.reflect_on_all_associations.select {|assoc| [nil,false].include?(assoc.options[:polymorphic])}.size
          @expected_include_array = [:friends, :love] # auto_references
        end

        should "have all his relationships as implicit configuration, except the excepted ones, defined for the plugin" do
          assert_equal @relationships_quantity-1, Person.search_index[:relationships].size
        end
        
        should "have include_array as expected" do
          assert (@expected_include_array | Person.get_include_array).size == 2 ## compare content without taking in account order
        end
      end

      context "with invalid :except_relationships" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :except_relationships => 'bad arg' }
        end
      end

      context "with :except_relationships set to :all" do
        setup do
          Person.has_search_index :except_relationships => :all
        end

        should "not have any relationships defined for the plugin" do
          assert_equal 0, Person.search_index[:relationships].size
        end
        
        should "have include_array as expected" do
          assert_equal [], Person.get_include_array
        end
      end

      context "with :only_relationships and :except_relationships both set" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :only_relationships => [:gender], :except_relationships => [:gender] }
        end
      end
    
      context "with implicit additional attributes definition" do
        
        should "not have any additional attributes defined for the plugin" do
          assert_equal 0, Person.search_index[:additional_attributes].size
        end
      end

      context "with valid :additional_attributes" do
        setup do
          Person.has_search_index :additional_attributes => {:name => :string}
        end

        should "have only these additional attributes defined for the plugin" do
          assert_equal 1, Person.search_index[:additional_attributes].size
        end
        
        should "store it into search_index_attributes" do
          assert Person.search_index_attributes.keys.include?('name')
        end
      end

      context "with invalid :additional_attributes" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.has_search_index :additional_attributes => [:name] }
        end
      end
    
      ### check sql option support
      context "with a relationship having :order and :macro in (:has_many, :has_and_belongs_to_many)" do
        setup do
          Person.reflect_on_association(:summer_jobs).options[:order] = 'created_at DESC, id Asc'
          Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
          @summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
          Person.has_search_index 
        end
          
        should "have :conditions properly generated" do
          assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions]
        end
        
        should "keep association behavior" do
          assert_equal @summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort
        end
      end
           
      context "with a relationship having :order and :macro in (:has_one, :belongs_to)" do
        setup do
          Person.reflect_on_association(:dog).options[:order] = 'created_at DESC'
          Person.reflect_on_association(:dog).options[:conditions] = nil
          @dog_id = Person.first.dog.id
          Person.has_search_index
        end
      
        should "have :conditions properly generated" do
          assert_not_nil Person.reflect_on_association(:dog).options[:conditions]
        end
        
        should "keep association behavior" do
          assert_equal @dog_id, Person.first.dog.id
        end
      end
      
      context "with a relationship having :group" do
        setup do
          Person.reflect_on_association(:summer_jobs).options[:group] = 'summer_jobs.salary'
          Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
          @summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
          Person.has_search_index
        end
      
        should "have :conditions properly generated" do
          assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions]
        end
        
        should "keep association behavior" do
          assert_equal @summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort
        end
      end
      
#      # FIXME uncomment that part when the bug with mysql subqueries will be fixed (http://dev.mysql.com/doc/refman/5.1/en/subquery-errors.html)
#      context "with a relationship having :limit without :offset" do
#        setup do
#          Person.reflect_on_association(:summer_jobs).options[:limit] = 2
#          Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
#          @summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
#          Person.has_search_index
#        end
#      
#        should "have :conditions properly generated" do
#          assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions]
#        end
#        
#        should "keep association behavior" do
#          assert_equal @summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort
#        end
#      end
# 
#      # FIXME uncomment that part when the bug with mysql subqueries will be fixed (http://dev.mysql.com/doc/refman/5.1/en/subquery-errors.html)
#      context "with a relationship having :limit and :offset" do
#        setup do
#          Person.reflect_on_association(:summer_jobs).options[:limit] = 3
#          Person.reflect_on_association(:summer_jobs).options[:offset] = 1
#          Person.reflect_on_association(:summer_jobs).options[:conditions] = nil
#          @summer_jobs_ids = Person.first.summer_jobs.collect(&:id).sort
#          Person.has_search_index
#        end
#      
#        should "have :conditions properly generated" do
#          assert_not_nil Person.reflect_on_association(:summer_jobs).options[:conditions]
#        end
#        
#        should "keep association behavior" do
#          assert_equal @summer_jobs_ids, Person.first.summer_jobs.collect(&:id).sort
#        end
#      end
      
      context "with relationship is 1-N" do
        setup do
          prepare_association(Person, :summer_jobs)
          @expected_conditions  = "`summer_jobs`.id in (SELECT `summer_jobs`.id FROM `summer_jobs`"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `summer_jobs`.person_id"
          @expected_conditions += " ORDER BY `summer_jobs`.created_at DESC)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:summer_jobs).options[:conditions].first
        end
      end
      
      context "with relationship is 1-N :polymorphic" do
        setup do
          prepare_association(Person, :numbers)
          @expected_conditions  = "`numbers`.id in (SELECT `numbers`.id FROM `numbers`"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `numbers`.has_number_id"
          @expected_conditions += " WHERE (`numbers`.has_number_type = 'Person') ORDER BY `numbers`.created_at DESC)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:numbers).options[:conditions].first
          
        end
      end
      
      context "with relationship is 1-1" do
        setup do
          prepare_association(Person, :dog)
          @expected_conditions  = "`dogs`.id = (SELECT `dogs`.id FROM `dogs`"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `dogs`.person_id"
          @expected_conditions += " ORDER BY `dogs`.created_at DESC LIMIT 1)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:dog).options[:conditions].first
        end
      end
      
      context "with relationship is 1-1 :polymorphic" do
        setup do
          prepare_association(Person, :identity_card)
          @expected_conditions  = "`identity_cards`.id = (SELECT `identity_cards`.id FROM `identity_cards`"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `identity_cards`.has_identity_card_id"
          @expected_conditions += " WHERE (`identity_cards`.has_identity_card_type = 'Person') ORDER BY `identity_cards`.created_at DESC LIMIT 1)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:identity_card).options[:conditions].first
        end
      end
      
      context "with relationship is 1-1 :through" do
        setup do
          prepare_association(Person, :love)
          @expected_conditions  = "`people`.id = (SELECT `people`.id FROM `people`"
          @expected_conditions += " INNER JOIN `familly_relationships` ON `people`.id = `familly_relationships`.love_id"
          @expected_conditions += " LEFT OUTER JOIN `people` love_people ON love_people.id = `familly_relationships`.person_id"
          @expected_conditions += " ORDER BY `people`.created_at DESC LIMIT 1)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:love).options[:conditions].first
        end
      end
      
      context "with relationship is 1-1 :through, :polymorphic" do
        setup do
          prepare_association(Person, :dream)
          @expected_conditions  = "`dreams`.id = (SELECT `dreams`.id FROM `dreams`"
          @expected_conditions += " INNER JOIN `people_dreams` ON `dreams`.id = `people_dreams`.dream_id"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `people_dreams`.has_dream_id"
          @expected_conditions += " WHERE (`people_dreams`.has_dream_type = 'Person') ORDER BY `dreams`.created_at DESC LIMIT 1)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:dream).options[:conditions].first
        end
      end
      
      context "with relationship is N-N" do
        setup do
          prepare_association(Person, :favorite_colors)
          @expected_conditions  = "`favorite_colors`.id in (SELECT `favorite_colors`.id FROM `favorite_colors`"
          @expected_conditions += " INNER JOIN `favorite_colors_people` ON `favorite_colors`.id = `favorite_colors_people`.favorite_color_id"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `favorite_colors_people`.person_id"
          @expected_conditions += " ORDER BY `favorite_colors`.created_at DESC)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:favorite_colors).options[:conditions].first
        end
      end
      
      context "with relationship is N-N :through" do
        setup do
          prepare_association(Person, :friends)
          @expected_conditions  = "`people`.id in (SELECT `people`.id FROM `people`"
          @expected_conditions += " INNER JOIN `relationships` ON `people`.id = `relationships`.friend_id"
          @expected_conditions += " LEFT OUTER JOIN `people` friends_people ON friends_people.id = `relationships`.person_id"
          @expected_conditions += " ORDER BY `people`.created_at DESC)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:friends).options[:conditions].first
        end
      end
      
      context "with relationship is N-N :through, :polymorphic" do
        setup do
          prepare_association(Person, :wishes)
          @expected_conditions  = "`wishes`.id in (SELECT `wishes`.id FROM `wishes`"
          @expected_conditions += " INNER JOIN `people_wishes` ON `wishes`.id = `people_wishes`.wish_id"
          @expected_conditions += " LEFT OUTER JOIN `people` ON `people`.id = `people_wishes`.has_wishes_id"
          @expected_conditions += " WHERE (`people_wishes`.has_wishes_type = 'Person') ORDER BY `wishes`.created_at DESC)"
          Person.has_search_index
        end
      
        should "have sub query in :conditions as expected" do
          assert_equal @expected_conditions, Person.reflect_on_association(:wishes).options[:conditions].first
        end
      end
      
    end
    #############################################
    ### Test standard search (search_with method)
    #############################################
    context "A standard search" do
      setup do
        Person.has_search_index :only_attributes => [:age], :additional_attributes => {:name => :string}
      end
      
      context "without any criteria" do
        setup do
          create_people
        end
        
        should "return all records" do
          assert_equal Person.all, Person.search_with
        end
      end
        
      
      context "with a wrong :search_type" do
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_with('name' => 'Doe', :search_type => 'wrong search_type') }
        end
      end
      
      context "with undefined relationship" do

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_with("wrong_relationship.name" => "value") }
        end
      end

      context "with undefined relationship (for the plugin)" do
        setup do
          Gender.has_search_index
          Person.has_search_index :except_relationships => [:gender]
        end
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_with("gender.name" => "value") }
        end
      end

      context "with undefined attribute" do
        setup do
          Gender.has_search_index
        end

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_with("gender.wrong_attribute" => "value") }
        end
      end

      context "with undefined attribute (for the plugin)" do
        setup do
          Gender.has_search_index :except_attributes => [:name]
        end

        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.search_with("gender.name" => "value") }
        end
      end
      
      ### Database attributes
      context "with only database attributes and" do
        setup do
          init_plugin_in_all_models
          Person.has_search_index
          @person = Person.create(:name => 'good', :age => 10)
        end
      
        context "with criterion's attribute is not nested" do
          setup do
            @expected = Person.all(:conditions => ['name like?', '%good%'])
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('name' => 'good')
          end
        end
        
        context "with criterion's attribute is nested" do
          setup do
            Gender.create(:name => 'femme')
            @person.update_attributes(:gender_id => Gender.first.id)
            @expected = Person.all(:include => [:gender], :conditions => ['genders.name like?', '%femme%'])
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('gender.name' => 'femme')
          end
        end
        
        context "with criterion's attribute is deeply nested" do
          setup do
            NumberType.create(:name => "mobile")
            number = Number.create(:number_type_id => NumberType.first.id)
            friend = Person.create(:name => 'friend')
            friend.numbers  << number
            @person.friends << friend
            @expected = Person.all(:include => [{:friends => [ {:numbers => [:number_type]} ] } ], :conditions => ['number_types.name like?', '%mobile%'])
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('friends.numbers.number_type.name' => 'mobile')
          end
        end
        
#        #FIXME That part don't work because of a bug when using eager loading with 'has_one :through' (http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_one#554-has-one-through-belongs-to-not-working)
#        context "with another complex nested attribute" do
#          setup do
#            NumberType.create(:name => "mobile")
#            number = Number.create(:number_type_id => NumberType.first.id)
#            friend = Person.create(:name => 'friend')
#            friend.numbers  << number
#            @person.friends << friend
#            
#            @expected = Person.all(:include => [{:love => [{:numbers => [:number_type]} ]} ], :conditions => ['number_types.name like?', '%mobile%'])
#          end
#        
#          should "should return as expected" do
#            assert_equal @expected, Person.search_with('love.numbers.number_type.name' => 'mobile')
#          end
#        end
        
        context "with criterion's value like ( 'value' )" do
          setup do
            @expected_conditions_array = ["(people.name like?)", '%good%']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => 'good')
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array, Person.send(:conditions_array ,Person, 'good', 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( 'value value2' )" do
          setup do
            @expected_conditions_array = ['(people.name like? and people.name like?)', '%go%','%od%']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => 'go od')
          end

          should "have expected conditions_array" do
            assert_equal @expected_conditions_array, Person.send(:conditions_array ,Person, 'go od', 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( 'value, value2' )" do
          setup do
            @expected_conditions_array = ['(people.name =? or people.name =?)', 'go','od']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'go, od', :action => "="})
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, {:value => 'go, od', :action => "="}, 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( 'value, value2 value3')" do
          setup do
            @expected_conditions_array = ['(people.name =? or (people.name =? and people.name =?))', 'go','od', 'ad']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'go, od ad', :action => "="})
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, {:value => 'go, od ad', :action => "="}, 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( {:value => 'value', ...} )" do
          setup do
            @expected_conditions_array = ['(people.name like?)', '%good%']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'good', :action => 'like'})
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, {:value => 'good', :action => 'like'}, 'people.name', 'and')
          end
        end
          
        context "with criterion's value like ( {:value => 'value value2', ...} )" do
          setup do
            @expected_conditions_array = ['(people.name =? and people.name =?)', 'go','od']
            @expected = Person.all(:conditions => @expected_conditions_array)
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'go od', :action => "="})
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, {:value => 'go od', :action => "="}, 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( [{:value => 'value', ...}, {:value => 'value2', ...}] )" do
          setup do
            @expected_conditions_array = ['(people.name =?) and (people.name !=?)', 'good', 'bad']
            @expected = Person.all(:conditions => @expected_conditions_array)
            @criterion_value = [{:value => 'good', :action => "="}, {:value => 'bad', :action => "!="}]
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => @criterion_value)
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, @criterion_value, 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( [{:value => 'value value2', ...}, {:value => 'value3 value4', ...}] )" do
          setup do
            conditions_text = '(people.name =? and people.name =?) and (people.name !=? or people.name !=?)'
            @expected_conditions_array = [conditions_text, 'go','od','ba','ad']
            @expected = Person.all(:conditions => @expected_conditions_array)
            @criterion_value = [{:value => 'go od', :action => "="}, {:value => 'ba ad', :action => "!="}]
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => @criterion_value)
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, @criterion_value, 'people.name', 'and')
          end
        end
        
        context "with criterion's value like ( [{:value => 'value, value2', ...}, {:value => 'value3, value4', ...}] )" do
          setup do
            conditions_text = '(people.name =? or people.name =?) and (people.name !=? and people.name !=?)'
            @expected_conditions_array = [conditions_text, 'go','od','ba','ad']
            @expected = Person.all(:conditions => @expected_conditions_array)
            @criterion_value = [{:value => 'go, od', :action => "="}, {:value => 'ba, ad', :action => "!="}]
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => @criterion_value)
          end
          
          should "have expected conditions_array" do
            assert_equal @expected_conditions_array,
              Person.send(:conditions_array, Person, @criterion_value, 'people.name', 'and')
          end
        end
        
        context "with :search_type is 'or'" do
          setup do
            @expected = Person.all(:conditions => ['name like? or name like?', '%good%', '%bad%'])
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "return results that match with at least one criterion" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'or')
          end
        end
        
        context "with :search_type is 'not'" do
          setup do
            @expected = Person.all(:conditions => ['name not like? and name not like?', '%good%', '%bad%'])
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "return results that match with no criterion" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'not')
          end
        end
        
        context "with :search_type is 'and'" do
          setup do
            @expected = Person.all(:conditions => ['name like? and name like?', '%good%', '%bad%'])
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "return results that match with all criteria" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'and')
          end
        end
        
        context "With attribute_type is boolean and value is false" do
          setup do
            Gender.has_search_index(:only_attributes => [:male])
            Person.has_search_index(:only_relationships => [:gender])
            @expected = Person.all(:include => [:gender], :conditions => ['genders.male = ? or genders.male IS NULL', false])
          end
          
          should "match with value is equal to 'false' or is null" do
            assert_equal @expected, Person.search_with('gender.male' => false)
          end
        end
        
        context "with attribute_type is string and value is blank" do
          setup do
            person = Person.new(Person.first.attributes)
            person.name = nil
            flunk "should create person" unless person.save
            @expected = Person.all(:conditions => ["name = '' or name is null"])
          end
          
          should "match with search for value is null" do
            assert_equal @expected, Person.search_with('name' => nil)
          end
          
          should "match with search for value is empty" do
            assert_equal @expected, Person.search_with('name' => '')
          end
        end
        
        context "with value is null" do
          setup do
            person = Person.new(Person.first.attributes)
            person.name = nil
            flunk "should create person" unless person.save
            @expected = Person.all(:conditions => ['name is null'])
          end
          
          should "match with search for value is null" do
            assert_equal @expected, Person.search_with('name' => nil)
          end
        end
        
        context "with value is blank and other not blank values" do
          setup do
            person = Person.new(Person.first.attributes)
            person.name = nil
            flunk "should create person" unless person.save
            @expected = Person.all(:conditions => ['name IS NULL or age = ?', 10])
          end
          
          should "match with search for value is null" do
            assert_equal @expected, Person.search_with('name' => nil,  'age' => 10 ,:search_type => :or)
          end
        end
        
      end
      
      ### Additional attributes
      context "with only additional attributes and" do
        setup do
          init_plugin_in_all_models
          Person.has_search_index :additional_attributes => {:name => :string} 
          @person = Person.create(:name => 'good', :age => 10)
        end
        
        context "with criterion's attribute is not nested" do
          setup do
            @expected = Person.all.select {|n| n.name =~ /good/ }
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('name' => 'good')
          end
        end
        
        context "with criterion's attribute is nested" do
          setup do
            Gender.has_search_index :additional_attributes => {:name => :string}
            Gender.create(:name => 'femme')
            @person.update_attributes(:gender_id => Gender.first.id)
            @expected = Person.all.select {|n| n.gender && n.gender.name =~ /femme/ }
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('gender.name' => 'femme')
          end
        end
        
        context "with criterion's attribute is deeply nested" do
          setup do
            NumberType.has_search_index :additional_attributes => {:name => :string}
            NumberType.create(:name => "mobile")
            number = Number.create(:number_type_id => NumberType.first.id)
            friend = Person.create(:name => 'friend')
            friend.numbers  << number
            @person.friends << friend
            @expected = Person.all.select {|n| n.friends.select {|p| p.numbers.select {|m| m.number_type.name =~ /mobile/ }.any? }.any? }
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('friends.numbers.number_type.name' => 'mobile')
          end
        end
        
        context "with criterion's value like ( 'value' )" do
          setup do
            @expected = Person.all.select {|n| n.name =~ /good/ }
          end
        
          should "should return as expected" do
            assert_equal @expected, Person.search_with('name' => 'good')
          end
        end
        
        context "with criterion's value like ( 'value value2' ) " do
          setup do
            @expected = Person.all.select {|n| [ /go/, /od/ ].select{|pattern| n.name =~ pattern}.many? }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => 'go od')
          end
        end
        
        context "with criterion's value like ( 'value, value2' ) " do
          setup do
            @expected = Person.all.select {|n| [ /go/, /od/ ].select{|pattern| n.name =~ pattern}.any? }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => 'go od')
          end
        end
        
        context "with criterion's value like ( 'value, value2 value3' ) " do
          setup do
            @expected = Person.all.select {|n| [ /go/, [ /od/, /ad/ ]].select{|m| (m.is_a?(Array) ? m.select{|pattern| n.name =~ pattern}.many? : n.name =~ m)}.any? }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => 'go od')
          end
        end
        
        context "with criterion's value like ( {:value => 'value', ...} )" do
          setup do
            @expected = Person.all.select {|n| n.name =~ /good/ }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'good', :action => 'like'})
          end
        end
          
        context "with criterion's value like ( {:value => 'value value2', ...} )" do
          setup do
            @expected = Person.all.select {|n| [ /go/, /od/, /go od/ ].select{|pattern| n.name =~ pattern}.any? }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => {:value => 'go od', :action => "like"})
          end
        end
        
        context "with criterion's value like ( [{:value => 'value', ...}, {:value => 'value2', ...}] ))" do
          setup do
            @expected = Person.all.select {|n| n.name.include?('good') && !n.name.include?('bad') }
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => [{:value => 'good', :action => "like"}, {:value => 'bad', :action => "not like"}])
          end
        end
        
        context "with criterion's value like ( [{:value => 'value value2', ...}, {:value => 'value3 value4', ...}] )" do
          setup do
            conditions_text = '(name =? and name =?) and (name !=? or name !=?)'
            @expected = Person.all.select {|n| [ /go/, /od/ ].select{|pattern| n.name =~ pattern}.many? &&
                                               ![ /ba/, /ad/ ].select{|pattern| n.name =~ pattern}.any?}
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => [{:value => 'go od', :action => "like"}, {:value => 'ba ad', :action => "not like"}])
          end
        end
        
        context "with criterion's value like ( [{:value => 'value, value2', ...}, {:value => 'value3, value4', ...}] )" do
          setup do
            conditions_text = '(name =? or name =?) and (name !=? and name !=?)'
            @expected = Person.all.select {|n| [ /go/, /od/ ].select{|pattern| n.name =~ pattern}.any? &&
                                               ![ /ba/, /ad/ ].select{|pattern| n.name =~ pattern}.many?}
          end
        
          should "return as expected" do
            assert_equal @expected, Person.search_with('name' => [{:value => 'go, od', :action => "like"}, {:value => 'ba, ad', :action => "not like"}])
          end
        end
        
        context "with :search_type 'or'" do
          setup do
            @expected = Person.all.select {|n| n.name =~ /good/ || n.name =~ /bad/ }
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "return results that match with at least one criterion" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'or')
          end
        end
        
        context "with :search_type 'not'" do
          setup do
            @expected = Person.all.select {|n| !(n.name =~ /good/) && !(n.name =~ /bad/) }
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "return results that match with no criterion" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'not')
          end
        end
        
        context "with :search_type 'and'" do
          setup do
            @expected = Person.all.select {|n| n.name =~ /good/ && n.name =~ /bad/ }
            @values   = [{:value => 'good', :action => 'like'},{:value => 'bad', :action => 'like'}]
          end
        
          should "description" do
            assert_equal @expected, Person.search_with('name' => @values, :search_type => 'and')
          end
        end

        context "" do
          setup do
            DataType.has_search_index :additional_attributes => { :a_string => :string, :a_binary => :binary, :a_text => :text, :a_integer => :integer,
                                                                  :a_float => :float, :a_boolean => :boolean, :a_datetime => :datetime,
                                                                  :a_date => :date, :a_decimal => :decimal}
            @DataTypes = {:string => "good", :binary => "0111 0001", :text => "lorem ipsum azerty toto",
                          :integer => 1, :float => 1.2, :decimal => 2.345, :boolean => true,
                          :datetime => DateTime.now, :date => Date.today}
          end
          
          context "with numbers, 100" do
            setup do
              @expected = [ DataType.create({:a_integer => 100, :a_float => 100.0, :a_decimal => 100.000}) ]
            end
            
            [:decimal, :float, :integer].each do |type|
              should "be > 20 for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => ">", :value => "20"})
              end
              
              should "be >= 20 for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => ">=", :value => "20"})
              end
              
              should "not be < 20 for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "<", :value => "20"})
              end
              
              should "not be <= 20 for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "<=", :value => "20"})
              end
              
              should "be != 20 for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "!=", :value => "20"})
              end
              
              should "not be = 20 for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "=", :value => "20"})
              end
            end
          end
          
          context "with dates, Today" do
            setup do
              @expected = [ DataType.create({:a_date => Date.today, :a_datetime => DateTime.now}) ]
            end
            
            [:date, :datetime].each do |type|
              should "be < Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "<", :value => Date.tomorrow.to_s})
              end
              
              should "be <= Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "<=", :value => Date.tomorrow.to_s})
              end
              
              should "not be > Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => ">", :value => Date.tomorrow.to_s})
              end
              
              should "not be >= Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => ">=", :value => Date.tomorrow.to_s})
              end
              
              should "be != Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "!=", :value => Date.tomorrow.to_s})
              end
              
              should "not be = Tomorrow for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "=", :value => Date.tomorrow.to_s})
              end
            end
          end
          
          
          context "with strings, '1001'" do
            setup do
              @expected = [ DataType.create({:a_string => "1001", :a_binary => "1001", :a_text => "1001"}) ]
            end
            
            [:string, :binary, :text].each do |type|
              should "be like '10' for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "like", :value => '10'})
              end

              should "be = '1001' for a #{ type.to_s.capitalize }" do
                assert_equal @expected, DataType.search_with("a_#{ type }" => {:action => "=", :value => '1001'})
              end
              
              should "not be not like '1001' for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "not like", :value => '1001'})
              end
              
              should "not be != '1001' for a #{ type.to_s.capitalize }" do
                assert_equal [], DataType.search_with("a_#{ type }" => {:action => "!=", :value => '1001'})
              end
            end
          end
          
          context "with booleans, true" do
            setup do
              @expected = [ DataType.create({:a_boolean => true}) ]
            end
              
            should "be = true" do
              assert_equal @expected, DataType.search_with('a_boolean' => {:action => "=", :value => 'true'})
            end
            
            should "not be != true" do
              assert_equal [], DataType.search_with('a_boolean' => {:action => "!=", :value => 'true'})
            end
          end
        
        end
      end
      
      ### Order
      context "with :order option" do
        setup do
          male = Gender.create(:name => "Male")
          female = Gender.create(:name => "Female")
          @person_1 = Person.create(:name => "Botte", :age => 21, :gender_id => male.id)
          @person_2 = Person.create(:name => "Durantes", :age => 24, :gender_id => male.id)
          @person_3 = Person.create(:name => "Botte", :age => 26, :gender_id => female.id)
          flunk "People should have been created #{Person.count}" unless Person.count == 3
          
          Person.has_search_index :only_attributes => [:age], :additional_attributes => {:name => :string}
        end
        
        context "that is not an Array" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:order => 'name') }
          end
        end
        
        context "that contain undefined attribute" do
        
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:order => ['undefined.attribute:Asc']) }
          end
        end
          
        context "that do not contain an order direction" do
          
          should "order Asc by default" do
            assert_equal Person.search_with(:order => ['name:Asc']), Person.search_with( :order => ['name'])
          end
        end
        
        context "that contain an order direction not in (Desc, Asc)" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:order => ['name:Down']) }
          end
        end
        
        context "for additional_attributes" do

          should "order as expected" do
            assert_equal [@person_1, @person_3, @person_2], Person.search_with(:order => ['name:Asc']) 
          end
        end

        context "for both database_attributes and additional_attributes" do

          should "order as expected" do
            assert_equal [@person_3, @person_1, @person_2], Person.search_with(:order => ['name:Asc', 'age:Desc'])
          end
        end

        context "for database_attribute" do

          should "order result descendant by :id" do
            assert_equal [@person_3, @person_2, @person_1],  Person.search_with(:order => ['age:Desc'])
          end
        end
        
        context "for nested additional_attributes" do
          setup do
            Gender.has_search_index :additional_attributes => {:name => :string}
          end
        
          should "return as expected" do
            assert_equal [@person_3, @person_1, @person_2], Person.search_with(:order => ['gender.name:Asc'])
          end
        end
          
        context "for nested database_attributes" do
          setup do
            Gender.has_search_index :only_attributes => [:name]
          end
        
          should "return as expected" do
            assert_equal [@person_3, @person_1, @person_2], Person.search_with(:order => ['gender.name:Asc'])
          end
        end
      end
      
      ### Group
      context "with :group option" do
        setup do
          male = Gender.create(:name => "Male")
          female = Gender.create(:name => "Female")
          @person_1 = Person.create(:name => "Botte", :age => 31, :gender_id => male.id)
          @person_2 = Person.create(:name => "Durantes", :age => 24, :gender_id => male.id)
          @person_3 = Person.create(:name => "Botte", :age => 26, :gender_id => female.id)
          @person_4 = Person.create(:name => "Botte", :age => 26, :gender_id => female.id)
          flunk "People should have been created" unless Person.all(:conditions => ['age > 20']).count == 4
          
          Person.has_search_index :only_attributes => [:age], :additional_attributes => {:name => :string}
        end
        
        context "that is not an Array" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:group => 'name') }
          end
        end
        
        context "that contain undefined attributes" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) {Person.search_with(:group => ['undefined.attribute'])}
          end
        end
        
        context "for additional_attributes" do

          should "group as expected" do
            assert_equal [@person_1, @person_3, @person_4, @person_2], Person.search_with(:group => ['name'])
          end
        end

        context "for both database_attributes and additional_attributes" do

          should "group as expected" do
            assert_equal [@person_3, @person_4, @person_1, @person_2], Person.search_with(:group => ['name', 'age'])
          end
        end

        context "for database_attribute" do

          should "group as expected" do
            assert_equal [@person_2, @person_3, @person_4, @person_1], Person.search_with(:group => ['age'])
          end
        end
        
        context "for nested additional_attributes" do
          setup do
            Gender.has_search_index :additional_attributes => {:name => :string}
          end
        
          should "return as expected" do
            assert_equal [@person_3, @person_4, @person_1, @person_2], Person.search_with(:group => ['gender.name'])
          end
        end
          
        context "for nested database_attributes" do
          setup do
            Gender.has_search_index :only_attributes => [:name]
          end
        
          should "return as expected" do
            assert_equal [@person_3, @person_4, @person_1, @person_2], Person.search_with(:group => ['gender.name'])
          end
        end
      end
      
      ### Group & Order
      context "with both group and order option" do
        setup do
          @person_1 = Person.create(:name => "Botte", :age => 31)
          @person_2 = Person.create(:name => "Durantes", :age => 24)
          @person_3 = Person.create(:name => "Botte", :age => 26)
          @person_4 = Person.create(:name => "Botte", :age => 26)
          @person_5 = Person.create(:name => "Durantes", :age => 26)
          flunk "People should have been created" unless Person.all(:conditions => ['age > 20']).count == 5
          
          Person.has_search_index :only_attributes => [:age, :id], :additional_attributes => {:name => :string}
        end

        context "for additional_attributes" do

          should "group and then order as expected" do
            assert_equal [@person_1, @person_3, @person_4, @person_2, @person_5],
              Person.search_with(:group => ['name'], :order => ['name:Desc'])
          end
        end

        context "for both database_attributes and additional_attributes" do

          should "group and then order as expected" do
            assert_equal [@person_3, @person_4, @person_1, @person_2, @person_5],
              Person.search_with(:group => ['name'], :order => ['age:Asc'])
          end
        end

        context "for database_attribute" do

          should "group and then order as expected" do
            assert_equal [@person_2, @person_5, @person_4, @person_3, @person_1],
              Person.search_with(:group => ['age'], :order => ['id:Desc'])
          end
        end
      end
      
      ### Quick (quick_search)
      context "with quick option" do
        setup do
          
        end
        
        context "that is not a hash" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:quick => ['attribute', 'another_attribute']) }
          end
        end
        
        context "that is a hash wihout value" do
        
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:quick => {:attributes => ['attribute']}) }
          end
        end
        
        context "that is a hash wihout attributes" do
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:quick => {:value => 'val ue'}) }
          end
        end
        
        context "that contains wrong attributes" do
          
          should "raise an ArgumentError" do
            assert_raise(ArgumentError) { Person.search_with(:quick => {:value => 'good', :attributes => ['undefined_attribute']}) }
          end
        end
        
        context "that contains database_attributes" do
          setup do
            Person.has_search_index(:only_attributes => [:name])
            flunk "person should be created" unless Person.create(:name => 'good', :age => 10)
            
            @expected = Person.all(:conditions => ['name like?', "%good%"])
          end
          
          should "return as expected" do
            assert_equal @expected, Person.search_with(:quick => {:value => 'good', :attributes => ['name']})
          end
        end
        
        context "that contains additional_attributes" do
          setup do
            Person.has_search_index(:additional_attributes => {:name => :string})
            flunk "person should be created" unless Person.create(:name => 'good', :age => 10)
            
            @expected = Person.all.select {|n| n.name =~ /good/ }
          end
          
          should "return as expected" do
            assert_equal @expected, Person.search_with(:quick => {:value => 'good', :attributes => ['name']})
          end
        end
        
        context "that contains both additional and database attributes" do
          setup do
            Person.has_search_index(:only_attributes => [:age], :additional_attributes => {:name => :string})
            flunk "person should be created" unless Person.create(:name => '10', :age => 10)
            flunk "person should be created" unless Person.create(:name => '11', :age => 10)
            flunk "person should be created" unless Person.create(:name => '12', :age => 12)
            @expected = Person.all(:conditions => ['age = ?', "10"]) | Person.all.select {|n| n.name =~ /10/ }
          end
            
          should "return as expected" do
            assert_equal @expected, Person.search_with(:quick => {:attributes => ['name', 'age'], :value => '10'})
          end
        end
        
        context "mixed with normal search attributes," do
          setup do
            Person.has_search_index(:only_attributes => [:identifier], :additional_attributes => {:name => :string})
            @people = []
            @people << Person.new(:name => 'franc',    :identifier => "10")
            @people << Person.new(:name => 'john',     :identifier => "11")
            @people << Person.new(:name => 'brian',    :identifier => "12")
            @people << Person.new(:name => 'fancesca', :identifier => "20")
            @people << Person.new(:name => 'jane',     :identifier => "21")
            @people << Person.new(:name => 'brice',    :identifier => "22")
            @people << Person.new(:name => 'foebe',    :identifier => "30")
            @people << Person.new(:name => 'jim',      :identifier => "31")
            @people << Person.new(:name => 'bayer',    :identifier => "32")
            
            (0..8).each do |i|
              flunk "person should be created" unless @people[i].save
            end
          end
          
          context "from all people with identifier containing 2" do
            setup do
              @expected = @people.select {|n| n.identifier.include?('2')}
              @options = {"identifier" => {:action => 'like', :value => '2'} }
            end
            
            # db & qdb
            should "return all with identifier containing 3" do
              a = @expected.select {|n| n.identifier.include?('30')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ['identifier'], :value => 30}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db & qadd
            should "return all with name containing 'e'" do
              a = @expected.select {|n| n.name.include?('e') }
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name"], :value => 'e'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db & qdb | qadd
            should "return all with name containing '3' OR with identifier containing '3'" do
              a = @expected.select {|n| n.name.include?('3') || n.identifier.include?('3') }
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name","identifier"], :value => '3'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
          end
          
          context "from all people with name containing 'n'" do 
            setup do
              @expected = @people.select {|n| n.name.include?('n')}
              @options = {"name" => {:action => 'like', :value => 'n'} }
            end
            
            # add & qdb
            should "return all with identifier containing '3'" do
              a = @expected.select {|n| n.identifier.include?('3')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ['identifier'], :value => 3}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # add & qadd
            should "return all with name containing 'o'" do
              a = @expected.select {|n| n.name.include?('o') }
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name"], :value => 'o'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # add & qdb | qadd
            should "return all with identifier containing 'a' OR with name containing 'a'" do
              a = @expected.select {|n| n.name.include?('a') || n.identifier.include?('a')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name","identifier"], :value => 'a'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
          end
          
          context "from all people with name containing 'a' OR identifier containing '1'" do
            setup do
              @expected = @people.select {|n| n.name.include?('a') || n.identifier.include?('1')}
              @options = {"name" => {:action => 'like', :value => 'a'},"identifier" => {:action => 'like', :value => '1'}, :search_type => 'or'}
            end
            
            # db | add & qdb
            should "return all with identifier containing 2" do
              a = @expected.select {|n| n.identifier.include?('2')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ['identifier'], :value => 2}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            
            # db | add & qadd
            should "return all with name contain 'j'" do
              a = @expected.select {|n| n.name.include?('j')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name"], :value => 'j'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db | add & qdb | qadd
            should "return all with identifier containing '0' OR with name containing '0'" do
              a = @expected.select {|n| n.name.include?('0') || n.identifier.include?('0')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name", "identifier"], :value => '0'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
          end
          
          context "from all people with name not containing 'a' AND identifier not containing '1'" do
            setup do
              @expected = @people.select {|n| !n.name.include?('a') && !n.identifier.include?('1')}
              @options = {"name" => {:action => 'like', :value => 'a'},"identifier" => {:action => 'like', :value => '1'}, :search_type => 'not'}
            end
            
            # db !& add & qdb
            should "return all with identifier containing 2" do
              a = @expected.select {|n| n.identifier.include?('2')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ['identifier'], :value => 2}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db !& add & qadd
            should "return all with name contain 'j'" do
              a = @expected.select {|n| n.name.include?('j')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name"], :value => 'j'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db !& add & qdb | qadd
            should "return all with identifier containing '0' OR with name containing '0'" do
              a = @expected.select {|n| n.name.include?('0') || n.identifier.include?('0')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name", "identifier"], :value => '0'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
          end
          
          context "from all people with name containing 'a' AND identifier containing '1'" do
            setup do
              @expected = @people.select {|n| n.name.include?('a') && n.identifier.include?('1')}
              @options = {"name" => {:action => 'like', :value => 'a'},"identifier" => {:action => 'like', :value => '1'} }
            end
            
            # db & add & qdb
            should "return all with identifier containing 2" do
              a = @expected.select {|n| n.identifier.include?('2')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ['identifier'], :value => 2}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db & add & qadd
            should "return all with name contain 'j'" do
              a = @expected.select {|n| n.name.include?('j')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name"], :value => 'j'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
            
            # db & add & qdb & qadd
            should "return all with identifier containing '0' OR with name containing '0'" do
              a = @expected.select {|n| n.name.include?('0') || n.identifier.include?('0')}
              b = Person.search_with(@options.merge(:quick => {:attributes => ["name", "identifier"], :value => '0'}))
              assert_equal(a.map(&:id).sort, b.map(&:id).sort)
            end
          end
          
        end
      end
      
    end
    ###########################################
    ### Test simple Search (search_with method)
    ###########################################
    context "A simple search" do
      setup do
        Person.has_search_index :only_attributes => [:name], :additional_attributes => {:age => :integer}
        @person_1 = Person.create(:age => 20, :name => 'Drall')
        @person_2 = Person.create(:age => 10, :name => 'Drill')
      end
      
      context "targeting an additional attribute" do
        
        should "return as expected" do
          assert_equal [@person_1], Person.search_with(20)
        end
      end
      
      context "targeting a database attribute" do
        
        should "return as expected" do
          assert_equal [@person_2], Person.search_with('Drill')
        end
      end
    end
    #########################
    ### Private methods tests
    #########################
    # generate_attribute_prefix + get_prefix_order
    context "generating attribute_prefix" do
    
      context "with an include_array containing 2 redundancy" do
        setup do
          @include_array = [{:love => [{:dog => [{:numbers => [:number_type]} ]} ]}, 
                                       {:dog => [{:numbers => [:number_type]} ]},
                                                 {:numbers => [:number_type]} ]
          @expected_redundant_paths = ['people.love.dog.numbers.number_type',
                                            'people.dog.numbers.number_type',
                                                'people.numbers.number_type']                                     
        end
        
        should "return redundant paths ordered as expected" do
          assert_equal @expected_redundant_paths, Person.send(:get_prefix_order, Person.table_name, @include_array, 'number_types')
        end
        
        context "and with a path that is the first to end with 'number_type'" do
          setup do
            @path = 'people.love.dog.numbers.number_type'
          end
          
          should "return original alias" do
            assert_equal 'number_types', Person.send(:generate_attribute_prefix, @path, @include_array)
          end
        end
        
        context "and with a path that is the second to end with 'number_type'" do
          setup do
            @path = 'people.dog.numbers.number_type'
          end
        
          should "return original alias prefixed with 'number_types'" do
            assert_equal 'number_types_numbers', Person.send(:generate_attribute_prefix, @path, @include_array)
          end
        end
        
        context "and with a path that is the third to end with 'number_type'" do
          setup do
            @path = 'people.numbers.number_type'
          end
        
          should "return original alias prefixed with 'number_types' and suffixed with '2'" do
            assert_equal 'number_types_numbers_2', Person.send(:generate_attribute_prefix, @path, @include_array)
          end
        end
      end
    end

    # match_regexp
    context "'match_regexp' method" do
      context "with matching simple pattern" do
        setup do
          @data = @pattern = 'string'
        end
      
        should "match data" do
          assert Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with not matching pattern" do
        setup do
          @data    = 'string'
          @pattern = 'strings'
        end
          
        should "not match data" do
          assert !Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with matching pattern that end with globbing (*)" do
        setup do
          @data =  'string.txt'
          @pattern = '*.txt'
        end
      
        should "match data" do
          assert Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with not matching pattern that end with globbing (*)" do
        setup do
          @data    = 'string.pdf'
          @pattern = '*.txt'
        end
          
        should "not match data" do
          assert !Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with matching pattern that start with globbing (*)" do
        setup do
          @data =  'string.txt'
          @pattern = 'string.*'
        end
      
        should "match data" do
          assert Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with not matching pattern that start with globbing (*)" do
        setup do
          @data    = 'array.txt'
          @pattern = 'string.*'
        end
          
        should "not match data" do
          assert !Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with matching pattern that both start and end with globbing (*)" do
        setup do
          @data =  'some_string.txt'
          @pattern = '*string*'
        end
      
        should "match data" do
          assert Person.send(:match_regexp, @data, @pattern)
        end
      end
      
      context "with not matching pattern that both start and end with globbing (*)" do
        setup do
          @data    = 'some_array.txt'
          @pattern = '*string*'
        end
          
        should "not match data" do
          assert !Person.send(:match_regexp, @data, @pattern)
        end
      end
    end
    
    # is_additional?
    context "'is_additional?' method" do
      
      context "for a database attribute" do
        setup do
          Person.has_search_index 
        end
      
        should "return false" do
          assert !Person.send(:is_additional?, 'name')
        end
      end
      
      context "for an additional attribute" do
        setup do
          Person.has_search_index(:additional_attributes => {:name => :string})
        end
      
        should "return true" do
          assert Person.send(:is_additional?, 'name')
        end
      end
      
      context "with wrong nested resource" do
        setup do
          Person.has_search_index
        end
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.send(:is_additional?, 'gander.name') }
        end
      end
      
      context "with nested resource that doesn't implement the plugin" do
        setup do
          Person.has_search_index
        end
        
        should "raise an ArgumentError" do
          assert_raise(ArgumentError) { Person.send(:is_additional?, 'gender.name') }
        end
      end
      
      context "with nested resource that implement the plugin" do
        setup do
          Person.has_search_index
          Gender.has_search_index :additional_attributes => {:name => :string}
        end
      
        should "return true" do
          assert Person.send(:is_additional?, 'gender.name')
        end
      end
        
    end
    
    # filter_include_array_from_paths
    context "'filter_include_array_from_paths' method" do
    
      context "with simple include" do
        setup do
          SummerJob.has_search_index :except_relationships => :all
          Person.has_search_index :only_relationships => [:summer_jobs]
          @include_array  = [:summer_jobs]
        end
      
        should "return full include_array" do
          assert_equal @include_array, Person.send(:filter_include_array_from_paths, @include_array, ['summer_jobs'])
        end
        
        should "return an empty Array" do
          assert_equal [], Person.send(:filter_include_array_from_paths, @include_array, [])
        end
      end
      
      context "with nested include" do
        setup do
          NumberType.has_search_index :except_relationships => :all
          Number.has_search_index :only_relationships => [:number_type]
          Person.has_search_index :only_relationships => [:summer_jobs, :numbers]
          @include_array  = [:summer_jobs, {:numbers => [:number_type]}]
        end
      
        should "return full include_array" do
          assert_equal @include_array,  Person.send(:filter_include_array_from_paths, @include_array, ['summer_jobs', 'numbers.number_type'])
        end
        
        should "return filtered include_array" do
          assert_equal [:summer_jobs, :numbers],  Person.send(:filter_include_array_from_paths, @include_array, ['summer_jobs', 'numbers'])
        end
        
        should "return an empty Array" do
          assert_equal [], Person.send(:filter_include_array_from_paths, @include_array, [])
        end
      end
        
    end
  
    # negative
    context "'negative' method" do
      positives = ["=",">","<","like","!=","<=",">=","not like"]
      negatives = ["!=","<=",">=","not like","=",">","<","like"]
      
      positives.each_with_index do |positive, i|
        should "return '#{negatives[i]}' for #{positive}" do
          assert_equal Person.send(:negative, positive), negatives[i]
        end
      end
    end
    
    # split_value
    context "'split_value' method" do
      setup do
        DataType.has_search_index
      end
      
      context "for an integer" do
        
        should "return an Array with 1 Integer" do
          assert_equal [[1]], DataType.send(:split_value, DataType, 'a_integer', '1')
        end
        
        should "return an Array with 1 Array of Integer" do
          assert_equal [[1, 0, 10]], DataType.send(:split_value, DataType, 'a_integer', '1 0 10')
        end
        
        should "return an Array with 2 Arrays of Integer" do
          assert_equal [[1],[ 0, 10]], DataType.send(:split_value, DataType, 'a_integer', '1, 0 10')
        end
      end
      
      context "for a boolean" do

        should "return an Array with 1 Boolean" do
          assert_equal [[true]], DataType.send(:split_value, DataType, 'a_boolean', '1')
        end
        
        should "return an Array with 1 Array of Boolean" do
          assert_equal [[true, false, false]], DataType.send(:split_value, DataType, 'a_boolean', '1 0 false')
        end
        
        should "return an Array with 2 Array of Boolean" do
          assert_equal [[true], [false, false]], DataType.send(:split_value, DataType, 'a_boolean', '1, 0 false')
        end
      end
      
      context "for a float" do

        should "return an Array with 1 Float" do
          assert_equal [[1.2]], DataType.send(:split_value, DataType, 'a_float', '1.2')
        end
        
        should "return an Array with 1 Array of Float" do
          assert_equal [[1.2, 0.45, 123.203]], DataType.send(:split_value, DataType, 'a_float', '1.2 0.45 123.203')
        end
        
        should "return an Array with 2 Array of Float" do
          assert_equal [[1.2], [0.45, 123.203]], DataType.send(:split_value, DataType, 'a_float', '1.2, 0.45 123.203')
        end
      end
      
      context "for a decimal" do

        should "return an Array with 1 Decimal" do
          assert_equal [[1000.2]], DataType.send(:split_value, DataType, 'a_decimal', '1000.2')
        end
        
        should "return an Array with 1 Array of Decimals" do
          assert_equal [[15.2, 0.45, 13.2]], DataType.send(:split_value, DataType, 'a_decimal', '15.2 0.45 13.2')
        end
        
        should "return an Array with 2 Array of Decimals" do
          assert_equal [[15.2], [0.45, 13.2]], DataType.send(:split_value, DataType, 'a_decimal', '15.2, 0.45 13.2')
        end
      end
      
      context "for a datetime" do

        should "return date time formatted in String within an Array" do
          assert_equal [['2009/9/30 9:43:00']], DataType.send(:split_value, DataType, 'a_datetime', '2009/9/30 9:43:00')
        end
      end
      
      context "for a String" do

        should "return an Array with 1 String" do
          assert_equal [['john']], DataType.send(:split_value, DataType, 'a_string', 'john')
        end
        
        should "return an Array with 1 Array of String" do
          assert_equal [['john', 'j', 'n']].sort, DataType.send(:split_value, DataType, 'a_string', 'john j n').sort
        end
        
        should "return an Array with 2 Array of String" do
          assert_equal [['john'], ['j', 'n']].sort, DataType.send(:split_value, DataType, 'a_string', 'john, j n').sort
        end
      end
      
      context "while skipping splitting" do

        should "return an Array with 1 String" do
          assert_equal [['john, is gone']], DataType.send(:split_value, DataType, 'a_text', '"john, is gone"')
        end
        
        should "return the unsplitted String with the splitted strings" do
          assert_equal [['john, is gone'], ['j', 'n']].sort,
                 DataType.send(:split_value, DataType, 'a_text', '"john, is gone", j n').sort
        end
      end
      
      context "while using an impair quantity of '\"'" do

        should "drop the last '\"'" do
          assert_equal 3, '" test, a sentence with many spaces " with another one " special caratere'.count('"')
          assert_equal [[' test, a sentence with many spaces ', 'with', 'another', 'one', 'special', 'caratere']],
                  DataType.send(:split_value, DataType, 'a_text', '" test, a sentence with many spaces " with another one " special caratere')
        end
      end
    end
    
    # organized_filters
    context "'organize_filters method'" do
      setup do
        NumberType.has_search_index :only_attributes => [:name]
        Number.has_search_index :only_attributes => [:value], :only_relationships => [:number_type]
        Person.has_search_index :only_attributes => [:name, :age], :only_relationships => [:numbers]
        @filters = [
          'name',
          'numbers.value',
          'numbers.number_type.name',
          'age'
        ]
        @expected = [
                      'name',
                      ['numbers', [ 
                          'numbers.value',
                          ['numbers.number_type', [
                              'numbers.number_type.name'
                            ]
                          ]
                        ],
                      ],
                      'age'
                    ]
      end
      
      should "organize filters as expected" do
        assert_equal @expected, HasSearchIndex.organized_filters(@filters, 'Person')
      end
    end    
  
    # get_nested_attribute_type
    context "'get_nested_attribute_type' method" do
      setup do
        NumberType.has_search_index :only_attributes => [:name]
        Number.has_search_index :only_attributes => [:id], :only_relationships => [:number_type]
        Person.has_search_index :only_attributes => [:created_at], :only_relationships => [:numbers]
      end
      
      context "with simple attribute" do
        setup do
          @expected = 'datetime'
        end
        
        should "return expected type" do
          assert_equal @expected, HasSearchIndex.get_nested_attribute_type('Person','created_at')
        end
      end
        
      context "with nested attribute" do
        setup do
          @expected = 'integer'
        end
        
        should "return expected type" do
          assert_equal @expected, HasSearchIndex.get_nested_attribute_type('Person','numbers.id')
        end
      end
      
      context "with deeply nested attribute" do
        setup do
          @expected = 'string'
        end
        
        should "return expected type" do
          assert_equal @expected, HasSearchIndex.get_nested_attribute_type('Person','numbers.number_type.name')
        end
      end
    end
      
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
