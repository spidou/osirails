require File.dirname(__FILE__) + '/../sales_test'

class ManufacturingStepTest < ActiveSupport::TestCase
  should_have_many :manufacturing_progresses
  
  should_belong_to :production_step
  
  #TODO validates_date :manufacturing_started_on
  #TODO validates_persistence_of :manufacturing_started_on, :manufacturing_finished_on, :manufacturing_progresses
  
  context "Given an order with 2 end_products, a manufacturing_step" do
    setup do
      @order = create_default_order
      @end_product1 = create_default_end_product(@order, :quantity => 10)
      @end_product2 = create_default_end_product(@order, :quantity => 20)
      
      @step = @order.production_step.manufacturing_step
      
      flunk "@order should have 2 end_products" unless @order.end_products.count == 2
    end
    
    #TODO review the following (ugly and uncomplete) tests
    
    #context "when manufacturing_started_on is define" do
    #  context "with good date" do
    #    setup do
    #      @step.manufacturing_started_on = Date.today
    #      @step.valid?
    #    end
    #    
    #    should "not have an error on manufacturing_started_on" do
    #      assert_nil @step.errors.on(:manufacturing_started_on)  
    #    end
    #  end
    #  
    #  context "with bad date" do
    #    setup do
    #      @step.manufacturing_started_on = Date.today + 5.days
    #      @step.valid?
    #    end
    #    
    #    should "have an error on manufacturing_started_on" do
    #      assert_not_nil @step.errors.on(:manufacturing_started_on)  
    #    end
    #  end      
    #end
    
    #context "when manufacturing_finished_on is define" do
    #  context "with good date" do
    #    setup do
    #      @step.manufacturing_started_on = Date.today - 6.days
    #      @step.manufacturing_finished_on = Date.today
    #      @step.valid?
    #    end
    #    
    #    context "when not progression is under 100" do
    #      should "have an error on manufacturing_finished_on" do
    #        assert_not_nil @step.errors.on(:manufacturing_finished_on)  
    #      end          
    #    end
    #  end
    #  
    #  context "with date less than manufacturing_started_on" do
    #    setup do
    #      @step.manufacturing_started_on = Date.today 
    #      @step.manufacturing_finished_on = Date.today - 6.days
    #      @step.valid?
    #    end
    #    
    #    should "have an error on manufacturing_finished_on" do
    #      assert_not_nil @step.errors.on(:manufacturing_started_on)  
    #    end
    #  end          
    #end
    
#    context "should be able to build manufacturing_progresses with end_product" do
#      setup do
#        @step.build_manufacturing_progresses_from_end_products
#      end
#      
#      should "have product in manufacturing_progresses equal to product in end_product" do
#        assert_equal @order.end_products.first, @step.manufacturing_progresses.first.product
#      end
#      
#      should "return a good number of product" do
#        assert_equal 1, @step.number_of_products
#      end
#      
#      should "return a good number of pieces" do
#        assert_equal 35, @step.number_of_pieces
#      end
#      
#      context "when manufacturing_step is saved" do
#        setup do
#          @step.manufacturing_progresses.first.progression = 0
#          @step.save!
#        end
#        
#        should "save manufacturing_progresses associated" do
#          assert !@step.manufacturing_progresses.first.new_record?
#        end
#        
#        context "when a manufacturing_progress is modified and step is saved again" do
#          setup do
#            flunk "progression should not be equal to 50" if @step.manufacturing_progresses.first.progression.to_i == 50
#            @step.manufacturing_progresses.first.progression = 50
#            @step.save!
#          end
#          
#          should "update manufacturing_progress attributes" do 
#             assert_equal 50, @step.manufacturing_progresses.first.progression
#          end
#        end
#        
#      end
#    end
  end
end
