require File.dirname(__FILE__) + '/../test_helper.rb'

class WatchableFunctionTest < ActiveRecordTestCase
  should_have_many :watchings_watchable_functions
  should_have_many :watchings, :through => :watchings_watchable_functions
  
  should_validate_presence_of :watchable_type, :name, :description
  
  should_validate_uniqueness_of :name, :scoped_to => :watchable_type
  
  context "A new watchable_function" do
    setup do
      @watchable_function = WatchableFunction.new
    end
    
    context "with 'on_modification' and 'on_schedule' at false" do
      setup do
        flunk "@watchable_function.on_modification should be at false" if @watchable_function.on_modification
        flunk "@watchable_function.on_schedule should be at false" if @watchable_function.on_schedule
        @watchable_function.valid?
      end
      
      should "have an invalid 'on_modification'" do
        assert_match I18n.t('activerecord.errors.messages.blank'), @watchable_function.errors.on(:on_modification)
      end
      
      should "have an invalid 'on_schedule'" do
        assert_match I18n.t('activerecord.errors.messages.blank'), @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "with 'on_modification' and 'on_schedule' at true" do
      setup do
        @watchable_function.on_modification = true
        @watchable_function.on_schedule = true
        @watchable_function.valid?
      end
      
      should "have a valid 'on_modification'" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "have a valid 'on_schedule'" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "with only 'on_modification' at true" do
      setup do
        @watchable_function.on_modification = true
        @watchable_function.on_schedule = false
        @watchable_function.valid?
      end
      
      should "have a valid 'on_modification'" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "have a valid 'on_schedule'" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "with only 'on_schedule' at true" do
      setup do
        @watchable_function.on_modification = false
        @watchable_function.on_schedule = true
        @watchable_function.valid?
      end
      
      should "have a valid 'on_modification'" do
        assert_nil @watchable_function.errors.on(:on_modification)
      end
      
      should "have a valid 'on_schedule'" do
        assert_nil @watchable_function.errors.on(:on_schedule)
      end
    end
  end
  
end
