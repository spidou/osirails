require 'test/unit'
require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsWatchableTest < ActiveRecordTestCase
  
  #assert_raise and nothing_raised pour la methode et l'argument'
  context "A Person whih implement acts_as_watcher" do
    should "raise an error when argument is bad" do
      assert_raise ArgumentError do
        Person.acts_as_watcher :email_methode => :email
      end
    end
    should "not raise an error when argument is good" do
      assert_nothing_raised ArgumentError do
        Person.acts_as_watcher :email_method => :email
      end
    end
    
    should "raise an error when mail method is bad" do
      assert_raise ArgumentError do
        Person.acts_as_watcher :email_methode => :emaile
      end
    end
    should "not raise an error when mail method is good" do
      assert_nothing_raised ArgumentError do
        Person.acts_as_watcher :email_method => :email
      end
    end
    
    should "not raise an error when argument and mail method is good" do
      assert_nothing_raised ArgumentError do
        Person.acts_as_watcher :email_method => :email
      end
    end
    
  end
  
  
  context "With Person implement ActsAsWatchable" do
    setup do
      Person.acts_as_watcher :email_method => :email
    end
  
    context "a new person" do
      setup do
        @person = Person.new
      end
      
      should "return this watcher type" do
        assert_equal "Person", @person.watcher_type
      end
        
      should "be able to call email_method" do
        assert @person.respond_to? "watcher_email"
      end
    end
  end
  
  context "With DISTRIC implement ActsAsWatchable" do
    setup do
      District.acts_as_watchable
      Person.acts_as_watcher :email_method => :email
    end
    
     context "a new district" do
      setup do
        @dupark = District.new
      end
      
      should "not have watchable" do
        assert_equal [], @dupark.watchables
      end
      
      should "not have all_changes_watchables" do
        assert_equal [], @dupark.all_changes_watchables
      end
    end
    
    context "a district" do
      setup do
        @district = create_a_district_with_its_representative
      end
      
      context "which is watched by a person with all modifications notify" do
        setup do
          @person = create_a_person
          @district = put_observation_on(@district, @person)
          flunk "should have at least a watchable" unless @district.watchables.size
        end

        should "be able to link the good user watcher" do
          assert_equal @person, @district.watchables.first.watcher
        end
        
        should "have empty watchable_function collection" do 
          assert @district.watchables.first.watchable_functions.empty?
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
              @district.area = 2000
              @district.save!
            end
            should "send one mail" do
              assert_equal 1,  ActionMailer::Base.deliveries.size
            end 
          end
                    
        end
      end
      
      context "which is watched by a person with observe a function" do
        setup do
          @person = create_a_person
          @district = put_observation_on(@district, @person)
          @district = put_relation_on_a_modification_watchable_function_for(@district)
          flunk "should have at least a watchable function" unless @district.watchables.first.watchables_watchable_functions.size >= 1
        end
        
        should "be able to verify function 'can_execute_instance_method'" do
          assert @district.can_execute_instance_method?(@district.watchables.first.watchables_watchable_functions.first)
        end

        context "when there are no modification execute_instance_method" do
          should "return false" do
            assert !@district.execute_instance_method(@district.watchables.first.watchables_watchable_functions.first)
          end
        end
        
        context "when there are a modification" do
          setup do
            ActionMailer::Base.deliveries = []
            @watchable = @district.watchables.first
            @watchable.all_changes = false
            @watchable.save!
            @district.area = 300
            flunk "area should be changed" unless @district.changed?
            flunk "should have 1 'on_modification_watchable_function'" unless @district.watchables.first.on_modification_watchable_functions.size == 1
          end
          
          should "return true when call should_deliver_email_for?(function)" do
            assert @district.send "should_deliver_email_for?", @district.watchables.first.watchables_watchable_functions.first
          end
          
          context "when district is saved" do
            setup do
              flunk "ActionMailer::Base.deliveries should be empty" unless ActionMailer::Base.deliveries.empty?
              @district.save!
            end
            
            should "send one mail" do
              assert_equal 1,  ActionMailer::Base.deliveries.size
            end 
            
            should "call super function and continue update" do
              assert_equal 300, @district.area_was
            end
          end   
        end
        
        context "when district is saved whith modification on an other attribute" do
          setup do
            ActionMailer::Base.deliveries = []
            @watchable = @district.watchables.first
            @watchable.all_changes = false
            @watchable.save!
            @watchable = @district.watchables.first
            @district.name = 'toto'
            @district.save!
          end
            
          should "not send mail" do
            assert ActionMailer::Base.deliveries.empty?
          end 
        end 
        
      end
      
    end
  end
 
  context "A watcher which observe a function on schedule" do
    setup do
      District.acts_as_watchable
      Person.acts_as_watcher :email_method => :email
      @district = create_a_district_with_its_representative
      @person = create_a_person
      ActionMailer::Base.deliveries = []
    end
    
    context "a district which have observable_function" do
      setup do
        @function = create_a_scheduled_watchable_function
        put_schedule_observation_on(@district, @person)
        @district = put_relation_on_a_schedule_watchable_function_for(@district, @function)
      end 
      
      should "have @function on this watchable_functions collection" do
        assert_equal @function, @district.watchable_functions.first 
      end
      
      context "when a cron is started and observable function return false" do
        setup do
          flunk "observable function should return false" if @district.area_is_too_short?
          flunk "ActionMailer::Base.deliveries should be empty" if ActionMailer::Base.deliveries.any?
          @district.deliver_email_for @district.watchables.first.watchables_watchable_functions.first, @district.watchables.first
        end
        
        should "not send mail" do
          assert ActionMailer::Base.deliveries.empty?
        end
      end
      
      context "when a cron is started there a modification on area and function must return true" do
        setup do
          @district.area = 50
          @district.save!
          flunk "observable function should return true" unless @district.area_is_too_short?
          ActionMailer::Base.deliveries = []
          @district.deliver_email_for  @district.watchables.first.watchables_watchable_functions.first, @district.watchables.first
        end
        
        should "send mail" do
          assert ActionMailer::Base.deliveries.any?
        end
      end
       
    end
    
  end
   
end






