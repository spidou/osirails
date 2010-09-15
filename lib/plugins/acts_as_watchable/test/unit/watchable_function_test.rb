require File.dirname(__FILE__) + '/../test_helper.rb'

class WatchableFunctionTest < ActiveRecordTestCase
  
  should_have_many :watchables_watchable_functions
  should_have_many :watchables, :through => :watchables_watchable_functions
  
  should_validate_presence_of :function_type, :function_name, :function_description
  
  context "a new watchable funtion" do
    setup do
      @watchable_function = WatchableFunction.new
    end
    
    context "whithout on_modification and on_schedule" do
      setup do
        @watchable_function.valid?
      end
      
      should "raise an error on on_modification" do
        assert_not_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "raise an error on on_schedule" do
        assert_not_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "whith on_modification and on_schedule" do
      setup do
        @watchable_function.on_modification = true
        @watchable_function.on_schedule = true
        @watchable_function.valid?
      end
      
      should "NOT raise an error on on_modification" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "NOT raise an error on on_schedule" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "whith on_modification and whithout on_schedule" do
      setup do
        @watchable_function.on_modification = true
        @watchable_function.on_schedule = true
        @watchable_function.valid?
      end
      
      should "NOT raise an error on on_modification" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "NOT raise an error on on_schedule" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "whithout on_modification and whith on_schedule" do
      setup do
        @watchable_function.on_modification = true
        @watchable_function.on_schedule = true
        @watchable_function.valid?
      end
      
      should "NOT raise an error on on_modification" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "NOT raise an error on on_schedule" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
  end
  
end












