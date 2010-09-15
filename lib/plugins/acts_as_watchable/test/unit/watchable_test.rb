require File.dirname(__FILE__) + '/../test_helper.rb'
class WatchableTest < ActiveRecordTestCase
  
  should_belong_to :has_watchable
  
  should_have_many :watchables_watchable_functions
  should_have_many :watchable_functions, :through => :watchables_watchable_functions
  should_have_many :on_modification_watchable_functions
  should_have_many :on_schedule_watchable_functions

  should_validate_presence_of :has_watchable_id, :has_watchable_type, :watcher_id
  
  context "a new watchable" do
    setup do
      @watchable_functions = []
      @watchable_functions << create_a_watchable_function 
      @watchable_functions << create_a_scheduled_watchable_function
      @watchable = Watchable.new
    end
    
    context "when build_watchables_watchable_function_with is used" do
      setup do
        flunk "watchables_watchable_functions should be empty" unless @watchable.watchables_watchable_functions.empty?
        @watchable.watchables_watchable_functions = @watchable.build_watchables_watchable_function_with(@watchable_functions)
      end
      
      should "have 2 watchables_watchable_fonctions in this collection" do
        assert_equal 2, @watchable.watchables_watchable_functions.size
      end
      
      context "when anything is selected" do
        setup do
          @watchable.build_watchables_watchable_function
          @watchable.build_watchables_watchable_function
        end
        
        should "return true when is all_watchables_watchable_functions_are_in_should_destroy? called" do
          assert @watchable.all_watchables_watchable_functions_are_in_should_destroy?
        end
      end
      
      context "when first watchable function is selected" do
        setup do
          @watchable.watchables_watchable_functions.first.on_modification = true
          @watchable.build_watchables_watchable_function
        end
        
        should "have put second watchables_watchable_function to should destroy" do
          assert @watchable.watchables_watchable_functions[1].should_destroy?
        end
        
        should "not return true when is all_watchables_watchable_functions_are_in_should_destroy? called" do
          assert !@watchable.all_watchables_watchable_functions_are_in_should_destroy?
        end
        
      end
    end
    context "when saved" do
        setup do
          @watchable.has_watchable_id = 1
          @watchable.has_watchable_type = "Test"
          @watchable.watcher_id = 1
          @watchable.all_changes = true
          @watchable.save! 
          flunk "@watchable should be saved" if @watchable.new_record?
        end
        
        context "when their are an other watchable with same value" do
          setup do
            @watchable_ = Watchable.new({:has_watchable_id => 1, :has_watchable_type => "Test", :watcher_id => 1, :all_changes => true})
            @watchable_.valid?
          end
          
          should "have error on has_watchable_id" do
            assert_not_nil @watchable_.errors.on(:has_watchable_id)
          end
        end
        
        context "when their are an other watchable with other value" do
          setup do
            @watchable_ = Watchable.new({:has_watchable_id => 2, :has_watchable_type => "Test", :watcher_id => 1, :all_changes => true})
            @watchable_.valid?
          end
          
          should "not have error on has_watchable_id" do
            assert_nil @watchable_.errors.on(:has_watchable_id)
          end

        end
        
      end
  end
  
end
