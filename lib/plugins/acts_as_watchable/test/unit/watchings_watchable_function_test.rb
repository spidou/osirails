require File.dirname(__FILE__) + '/../test_helper.rb'

class WatchingsWatchableFunctionTest < ActiveRecordTestCase
  should_belong_to :watching, :watchable_function
  
  should_validate_presence_of :watchable_function_id
  
  context "A new watchings_watchable_function" do
    setup do
      @watchings_watchable_function = WatchingsWatchableFunction.new
    end
    
    context "with 'on_schedule' at true" do
      setup do
        @watchings_watchable_function.on_schedule = true 
        flunk "@watchings_watchable_function.on_schedule should be at true" unless @watchings_watchable_function.on_schedule
      end
      
      subject{ @watchings_watchable_function }
      
      should_validate_presence_of :time_unity
    end
    
    context "with 'on_schedule' at false" do
      setup do
        @watchings_watchable_function.valid?
        flunk "@watchings_watchable_function.on_schedule should be at false" if @watchings_watchable_function.on_schedule
      end
      
      should "NOT require time_unity" do
        assert_nil @watchings_watchable_function.errors.on(:time_unity)
      end
    end
    
    # TODO tests 'on_schedule' is required when 'on_modification' is false, and vice-versa
  end
  
  context "A new watchings_watchable_function" do
    setup do
      @watchings_watchable_function = WatchingsWatchableFunction.new
    end
    
    context "- associated to a watchable_function which is set to be only 'on_modification' -" do
      setup do
        @watchable_function = WatchableFunction.new( :watchable_type  => "District",
                                                     :name            => "modification_on_area?",
                                                     :description     => "verify modification on area",
                                                     :on_modification => true,
                                                     :on_schedule     => false )
        @watchable_function.save!
        
        @watchings_watchable_function.watchable_function_id = @watchable_function.id
      end
      
      should "be able to be 'on_modification'" do
        @watchings_watchable_function.on_modification = true
        @watchings_watchable_function.valid?
        assert_nil @watchings_watchable_function.errors.on(:on_modification)
      end
      
      should "NOT be able to be 'on_schedule'" do
        @watchings_watchable_function.on_schedule = true
        @watchings_watchable_function.valid?
        assert_match I18n.t('activerecord.errors.models.watchings_watchable_function.attributes.on_schedule.is_not_blank'), @watchings_watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "- associated to a watchable_function which is set to be only 'on_schedule' -" do
      setup do
        @watchable_function = WatchableFunction.new( :watchable_type  => "District",
                                                     :name            => "modification_on_area?",
                                                     :description     => "verify modification on area",
                                                     :on_modification => false,
                                                     :on_schedule     => true )
        @watchable_function.save!
        
        @watchings_watchable_function.watchable_function_id = @watchable_function.id
      end
      
      should "NOT be able to be 'on_modification'" do
        @watchings_watchable_function.on_modification = true
        @watchings_watchable_function.valid?
        assert_match I18n.t('activerecord.errors.models.watchings_watchable_function.attributes.on_modification.is_not_blank'), @watchings_watchable_function.errors.on(:on_modification)
      end
      
      should "be able to be 'on_schedule'" do
        @watchings_watchable_function.on_schedule = true
        @watchings_watchable_function.valid?
        assert_nil @watchings_watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "- associated to a watchable_function which is set to be 'on_modification' AND 'on_schedule' -" do
      setup do
        @watchable_function = WatchableFunction.new( :watchable_type  => "District",
                                                     :name            => "modification_on_area?",
                                                     :description     => "verify modification on area",
                                                     :on_modification => true,
                                                     :on_schedule     => true )
        @watchable_function.save!
        
        @watchings_watchable_function.watchable_function_id = @watchable_function.id
      end
      
      should "be able to be 'on_modification'" do
        @watchings_watchable_function.on_modification = true
        @watchings_watchable_function.valid?
        assert_nil @watchings_watchable_function.errors.on(:on_modification)
      end
      
      should "be able to be 'on_schedule'" do
        @watchings_watchable_function.on_schedule = true
        @watchings_watchable_function.valid?
        assert_nil @watchings_watchable_function.errors.on(:on_schedule)
      end
      
      should "be able to be 'on_modification' and 'on_schedule simultaneously'" do
        @watchings_watchable_function.on_modification = true
        @watchings_watchable_function.on_schedule = true
        @watchings_watchable_function.valid?
        assert_nil @watchings_watchable_function.errors.on(:on_modification)
        assert_nil @watchings_watchable_function.errors.on(:on_schedule)
      end
      
      should "require at least one of 'on_schedule' or 'on_modification'" do
        @watchings_watchable_function.on_modification = false
        @watchings_watchable_function.on_schedule = false
        @watchings_watchable_function.valid?
        assert_match I18n.t('activerecord.errors.models.watchings_watchable_function.attributes.on_modification.is_blank'), @watchings_watchable_function.errors.on(:on_modification)
        assert_match I18n.t('activerecord.errors.models.watchings_watchable_function.attributes.on_schedule.is_blank'), @watchings_watchable_function.errors.on(:on_schedule)
      end
    end
  end
  
end
