require File.dirname(__FILE__) + '/../test_helper.rb'

class WatchablesWatchableFunctionTest < ActiveRecordTestCase
  
  should_belong_to :watchable
  should_belong_to :watchable_function
  
  should_validate_presence_of :watchable_id, :watchable_function_id
  
  #validation sur on_modification et on_schedule
  
  context "A new watchable function" do
    setup do
      @watchables_watchable_function = WatchablesWatchableFunction.new({:watchable_id => 1, :watchable_function_id => 1})
    end
    
    context "with presence of :on_schedule" do
      setup do
        @watchables_watchable_function.on_schedule = true 
      end
      subject {@watchables_watchable_function}
      should_validate_presence_of :time_unity
    end
    
    context "without presence of :on_schedule" do
      
      setup do
        @watchables_watchable_function.valid?
      end
      
      should "not validate presence of time_unity" do
        assert_nil @watchables_watchable_function.errors.on(:time_unity)
      end
    end   
  end
  
  context "a new watchable funtion" do
    setup do
      @watchables_watchable_function = WatchablesWatchableFunction.new
    end
    
    context "whith watchable_function" do
      setup do
        @watchable_function = WatchableFunction.new({:function_type => "District", 
                                        :function_name => "modification_on_area?", 
                                        :function_description => "verify modification on area",
                                        :on_modification => true  
                                        })
        
        #@watchable_function.save!                                
      end
      
      context "whithout on_schedule and whith on_schedule on watchables_watchable_function" do
        setup do
          @watchable_function.on_modification = true
          @watchable_function.on_schedule = nil
          @watchable_function.save!
          @watchables_watchable_function.watchable_function_id = @watchable_function.id
          @watchables_watchable_function.on_schedule = true
          @watchables_watchable_function.valid?
        end 
        
        should "raise an error on 'on_schedule'" do
          assert_not_nil @watchables_watchable_function.errors.on(:on_schedule)
        end
      end
      
      context "whithout on_modification and whith on_modifition on watchables_watchable_function" do
        setup do
          @watchable_function.on_modification = nil
          @watchable_function.on_schedule = true
          @watchable_function.save!
          @watchables_watchable_function.watchable_function_id = @watchable_function.id
          @watchables_watchable_function.on_modification = true
          @watchables_watchable_function.valid?
        end 
        
        should "raise an error on 'on_modification'" do
          assert_not_nil @watchables_watchable_function.errors.on(:on_modification)
        end
      end
    end
    
    context "whith on_modification and on_schedule" do
      setup do
        @watchables_watchable_function.on_modification = true
        @watchables_watchable_function.on_schedule = true
        @watchables_watchable_function.valid?
      end
      
      should "NOT raise an error on on_modification" do
        assert_nil @watchables_watchable_function.errors.on(:on_modification)
      end
      
      should "NOT raise an error on on_schedule" do
        assert_nil @watchables_watchable_function.errors.on(:on_schedule)
      end
    end
    
    context "whith on_modification and whithout on_schedule" do
      setup do
        @watchables_watchable_function.on_modification = true
        @watchables_watchable_function.on_schedule = true
        @watchables_watchable_function.valid?
      end
      
      should "NOT raise an error on on_modification" do
        assert_nil @watchables_watchable_function.errors.on(:on_modification)
      end
      
      should "NOT raise an error on on_schedule" do
        assert_nil @watchables_watchable_function.errors.on(:on_schedule)
      end
    end
    
  end
  
end

