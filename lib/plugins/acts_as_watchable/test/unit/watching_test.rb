require File.dirname(__FILE__) + '/../test_helper.rb'

class WatchingTest < ActiveRecordTestCase
  should_belong_to :watchable
  
  should_have_many :watchings_watchable_functions
  should_have_many :watchable_functions,                  :through => :watchings_watchable_functions
  should_have_many :on_modification_watchable_functions,  :through => :watchings_watchable_functions
  should_have_many :on_schedule_watchable_functions,      :through => :watchings_watchable_functions
  
  should_validate_presence_of :watchable_type, :watchable_id
  
  should_validate_uniqueness_of :watchable_id, :scoped_to => [:watchable_type, :watcher_id]
  
  context "(Given that District implements acts_as_watchable) A new watching" do
    setup do
      District.acts_as_watchable
      Person.acts_as_watcher :email_method => :email
      
      @watchable = District.first
      flunk "@watchable should be valid => #{@watchable.errors.full_messages.join(',')}" unless @watchable.valid?
      
      @watching = build_valid_watching_for(District.first)
    end
    
    context "- unassociated to a watchable -" do
      setup do
        @watching.watchable = nil
        flunk "@watching.watchable should be nil" if @watching.watchable
      end
      
      # test build_missing_watchings_watchable_functions
      context "in which we call 'build_missing_watchings_watchable_functions'" do
        setup do
          @watching.build_missing_watchings_watchable_functions
        end
        
        should "have NOT built any watchings_watchable_functions" do
          assert_equal [], @watching.watchings_watchable_functions
        end
      end
    end
    
    context "- associated to a watchable (District) which have 2 watchable_functions -" do
      setup do
        @watchable_function1 = create_a_watchable_function(:name => "method1")
        @watchable_function2 = create_a_watchable_function(:name => "method2")
        
        flunk "@watchable should have 2 watchable_functions" unless @watchable.watchable_functions.count == 2
        flunk "@watchable.watchable_functions should include @watchable_function1" unless @watchable.watchable_functions.include?(@watchable_function1)
        flunk "@watchable.watchable_functions should include @watchable_function2" unless @watchable.watchable_functions.include?(@watchable_function2)
        
        flunk "@watching.watchable should be @watchable" unless @watching.watchable == @watchable
      end
      
      # test build_missing_watchings_watchable_functions
      context "in which we call 'build_missing_watchings_watchable_functions'" do
        setup do
          @watching.build_missing_watchings_watchable_functions
        end
        
        should "have built 2 watchings_watchable_functions linked to the good watchable_functions" do
          assert_equal 2, @watching.watchings_watchable_functions.size
          assert_equal [@watchable_function1, @watchable_function2], @watching.watchings_watchable_functions.collect(&:watchable_function)
        end
      end
      
      context "which have 2 watchings_watchable_functions" do
        setup do
          @watching.build_missing_watchings_watchable_functions
          flunk "@watching should have <2> watchings_watchable_functions, but has <#{@watching.watchings_watchable_functions.size}>" unless @watching.watchings_watchable_functions.size == 2
        end
        
        # test all_watchings_watchable_functions_should_be_destroyed?
        context "set up to be triggered 'on_modification'" do
          setup do
            @watching.watchings_watchable_functions.each{ |f| f.on_modification = true }
            @watching.save!
            flunk "@watching should have 2 'on_modification' watchings_watchable_functions" unless @watching.watchings_watchable_functions.reject(&:new_record?).select(&:on_modification).size == 2
          end
          
          should "NOT have all_watchings_watchable_functions_should_be_destroyed" do
            assert !@watching.all_watchings_watchable_functions_should_be_destroyed?
          end
        end
        
        # test mark_to_destroy_unselected_items and all_watchings_watchable_functions_should_be_destroyed?
        context "NOT set up to be triggered" do # on_modification and on_schedule at false
          setup do
            @watching.watchings_watchable_functions.each{ |f| f.on_modification = true }
            @watching.save!
            
            @watching.watchings_watchable_functions.each{ |f| f.on_modification = false }
            @watching.watchings_watchable_functions.each{ |f| f.on_schedule = false }
            flunk "@watching should have 0 selected watchings_watchable_functions" unless @watching.watchings_watchable_functions.select(&:selected?).empty?
            
            flunk "@watching should have 2 watchings_watchable_functions" unless @watching.watchings_watchable_functions.reject(&:should_destroy?).size == 2
            @watching.valid?
          end
          
          should "mark all watchings_watchable_functions to be destroyed" do
            assert @watching.watchings_watchable_functions.reject(&:should_destroy?).empty?
          end
          
          should "have all_watchings_watchable_functions_should_be_destroyed" do
            assert @watching.all_watchings_watchable_functions_should_be_destroyed?
          end
        end
        
        # test all_watchings_watchable_functions_should_be_destroyed?
        context "marked to be destroyed" do
          setup do
            @watching.watchings_watchable_functions.each{ |f| f.should_destroy = true }
            flunk "@watching.watchings_watchable_functions should all be marked to be destroyed" unless @watching.watchings_watchable_functions.reject(&:should_destroy?).empty?
          end
          
          should "have all_watchings_watchable_functions_should_be_destroyed" do
            assert @watching.all_watchings_watchable_functions_should_be_destroyed?
          end
        end
      end
    end
  end
  
end
