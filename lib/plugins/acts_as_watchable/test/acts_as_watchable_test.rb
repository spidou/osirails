require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsWatchableTest < ActiveRecordTestCase
  
  setup do
    %w(district person school).each do |file_name|
      load "fixtures/#{file_name}.rb" 
    end
    
    %w(watchable_function watching watchings_watchable_function).each do |file_name|
      load "#{RAILS_ROOT}/../app/models/#{file_name}.rb" 
    end
  end
  
  teardown do
    %w(District Person School WatchableFunction Watching WatchingsWatchableFunction).each do |constant|
      Object.send(:remove_const, constant.to_sym) if Object.const_defined?(constant)
    end
    ActsAsWatchable.send(:remove_const, "WatcherClassName") if ActsAsWatchable.const_defined?("WatcherClassName")
  end
  
  ## ActsAsWatcher tests
  context "An active_record model which implements acts_as_watcher" do
    context "without the :email_method argument" do
      setup do
        # nothing to do
      end
      
      should "raise an argument error" do
        assert_raise ArgumentError do
          Person.acts_as_watcher
        end
      end
    end
    
    context "with the :email_method argument" do
      setup do
        # nothing to do
      end
      
      should "not raise an error" do
        assert_nothing_raised do
          Person.acts_as_watcher :email_method => :email
        end
      end
    end
    
    context "" do # just to handle setup for the following test
      setup do
        flunk "Watching should not have an association named 'watcher' #{Watching.reflect_on_association(:watcher).inspect}" if Watching.reflect_on_association(:watcher)
        Person.acts_as_watcher :email_method => :email
      end
      
      should "provide to Watching a belongs_to association called 'watcher'" do
        assert_not_nil Watching.reflect_on_association(:watcher)
        assert_equal :belongs_to, Watching.reflect_on_association(:watcher).macro
      end
    end
  end
  
  context "Given a first active_record model implements acts_as_watcher, another active_record model" do
    setup do
      Person.acts_as_watcher :email_method => :email
    end
    
    should "NOT be able to implement acts_as_watcher" do
      assert_raise ActsAsWatchable::ActsAsWatchableMultipleCallError do
        School.acts_as_watcher :email_method => :email
      end
    end
  end
  
  context "An instance of acts_as_watcher model" do
    setup do
      Person.acts_as_watcher :identifier_method => :identifier, :email_method => :email
      @person = Person.new
      
      flunk "@person.identifier should return 'this is me'" unless @person.identifier == 'this is me'
      flunk "@person.email should return 'foo@bar.com'" unless @person.email == 'foo@bar.com'
    end
    
    should "have a valid watcher_identifier" do
      assert_equal 'this is me', @person.watcher_identifier
    end
    
    should "have a valid watcher_email" do
      assert_equal 'foo@bar.com', @person.watcher_email
    end
    
    should "have a valid watcher_type" do
      assert_equal 'Person', @person.watcher_type
    end
  end
  
  
  ## ActsAsWatchable tests
  context "A instance of acts_as_watchable model" do
    setup do
      District.acts_as_watchable :identifier_method => :identifier
      @district = District.new
      
      flunk "@district.identifier should return 'yeah this is me'" unless @district.identifier == 'yeah this is me'
    end
    
    should "have 0 watchable_functions" do
      assert_equal [], @district.watchable_functions
    end
    
    should "have 0 watchable_function_ids" do
      assert_equal [], @district.watchable_function_ids
    end
    
    should "have a valid watchable_identifier" do
      assert_equal 'yeah this is me', @district.watchable_identifier
    end
    
    should "have 0 watchings" do
      assert_equal [], @district.watchings
    end
    
    should "have 0 all_changes_watchings" do
      assert_equal [], @district.all_changes_watchings
    end
  end
  
  context "Given that the model District implements acts_as_watchable," do
    #TODO these following test need to be reviewed
    #TODO check if the sent emails are well-formed
    setup do
      Person.acts_as_watcher :email_method => :email
      District.acts_as_watchable
    end
    
    context "a district" do
      setup do
        @district = create_a_district_with_its_representative
      end
      
      context "which is watched by a person with all modifications notify" do
        setup do
          @person = create_a_person
          @district = put_observation_on(@district, @person)
          flunk "should have at least 1 watching" unless @district.watchings.size
        end
        
        should "be able to link the good user watcher" do
          assert_equal @person, @district.watchings.first.watcher
        end
        
        should "have empty watchable_function collection" do
          assert @district.watchings.first.watchable_functions.empty?
        end
        
        context "when there are modification on area" do
          setup do
            @district.area = 2000
            ActionMailer::Base.deliveries = []
          end
          
          should "detect changes when use 'attributes_changed?'" do
            assert @district.attributes_changed?(["area"])
          end
          
          context "when @district is save" do
            setup do
              @district.save!
            end
            
            should "send 1 email" do
              assert_equal 1, ActionMailer::Base.deliveries.size
            end
          end
          
        end
      end
      
      context "which is watched by a person with observe a function" do
        setup do
          @person = create_a_person
          @district = put_observation_on(@district, @person)
          @district = put_relation_on_a_modification_watchable_function_for(@district)
          flunk "should have at least 1 watching_function" unless @district.watchings.first.watchings_watchable_functions.size >= 1
        end
        
        should "be able to verify function 'can_execute_instance_method'" do
          assert @district.can_execute_instance_method?(@district.watchings.first.watchings_watchable_functions.first.watchable_function)
        end
        
        context "when there are no modification execute_instance_method" do
          should "return false" do
            assert !@district.execute_instance_method(@district.watchings.first.watchings_watchable_functions.first.watchable_function)
          end
        end
        
        context "when there are a modification" do
          setup do
            ActionMailer::Base.deliveries = []
            @watching = @district.watchings.first
            @watching.all_changes = false
            @watching.save!
            @district.area = 300
            flunk "area should have changed" unless @district.changed?
            flunk "should have 1 'on_modification_watchable_function'" unless @district.watchings.first.on_modification_watchable_functions.size == 1
          end
          
          should "return true when call should_deliver_email_for?(function)" do
            assert @district.send("should_deliver_email_for?", @district.watchings.first.watchings_watchable_functions.first.watchable_function)
          end
          
          context "when district is saved" do
            setup do
              flunk "ActionMailer::Base.deliveries should be empty" unless ActionMailer::Base.deliveries.empty?
              @district.save!
            end
            
            should "send 1 email" do
              assert_equal 1,  ActionMailer::Base.deliveries.size
            end
            
            should "update record successfully after sending email" do
              assert_equal 300, @district.area_was
            end
          end
        end
        
        context "when district is saved whith modification on an other attribute" do
          setup do
            ActionMailer::Base.deliveries = []
            @watching = @district.watchings.first
            @watching.all_changes = false
            @watching.save!
            @watching = @district.watchings.first
            @district.name = 'toto'
            @district.save!
          end
            
          should "NOT send any email" do
            assert ActionMailer::Base.deliveries.empty?
          end 
        end 
        
      end
      
    end
  end
  
  context "A watcher which observe a function on schedule" do
    #TODO these following test need to be reviewed
    #TODO check if the sent emails are well-formed
    setup do
      District.acts_as_watchable
      Person.acts_as_watcher :email_method => :email
      @district = create_a_district_with_its_representative
      @person = create_a_person
      ActionMailer::Base.deliveries = []
    end
    
    context "a district which have observable_function" do
      setup do
        @watchable_function = create_a_watchable_function(:name             => 'area_is_too_short?',
                                                          :on_schedule      => true,
                                                          :on_modification  => false)
        put_schedule_observation_on(@district, @person)
        @district = put_relation_on_a_schedule_watchable_function_for(@district, @watchable_function)
      end 
      
      should "have @watchable_function on this watchable_functions collection" do
        assert_equal @watchable_function, @district.watchable_functions.first 
      end
      
      context "when a cron is started and observable function return false" do
        setup do
          flunk "observable function should return false" if @district.area_is_too_short?
          flunk "ActionMailer::Base.deliveries should be empty" if ActionMailer::Base.deliveries.any?
          @district.deliver_email_for(@watchable_function, @district.watchings.first)
        end
        
        should "NOT send any email" do
          assert ActionMailer::Base.deliveries.empty?
        end
      end
      
      context "when a cron is started there a modification on area and function must return true" do
        setup do
          @district.area = 50
          @district.save!
          flunk "observable function should return true" unless @district.area_is_too_short?
          ActionMailer::Base.deliveries = []
          @district.deliver_email_for(@watchable_function, @district.watchings.first)
        end
        
        should "send 1 email" do
          assert ActionMailer::Base.deliveries.any?
        end
      end
    end
  end
   
end
