require File.dirname(__FILE__) + '/../sales_test'

class ProductionStepTest < ActiveSupport::TestCase
  should_have_many :production_progresses
 
  context "a production_step" do
    setup do 
      @survey = create_default_order.commercial_step.survey_step
      create_default_end_product_for(@survey, {:quantity => 35 })
      @step = @survey.order.pre_invoicing_step.production_step
      flunk "employees table should have at least 2 records" unless Employee.count >= 2
      flunk "order end_products should not be empty" if @survey.order.end_products.empty?
      flunk "survey_interventions should be empty" unless @survey.survey_interventions.empty?
    end  
    
    context "when begining_production_on is define" do
      context "with good date" do
        setup do
          @step.begining_production_on = Date.today
          @step.valid?
        end
        
        should "not have an error on begining_production_on" do
          assert_nil @step.errors.on(:begining_production_on)  
        end
      end
      
      context "with bad date" do
        setup do
          @step.begining_production_on = Date.today  + 5.days
          @step.valid?
        end
        
        should "have an error on begining_production_on" do
          assert_not_nil @step.errors.on(:begining_production_on)  
        end
      end      
    end
    
    context "when ending_production_on is define" do
      context "with good date" do
        setup do
          @step.begining_production_on = Date.today - 6.days
          @step.ending_production_on = Date.today
          @step.valid?
        end
        
        context "when not progression is under 100" do
          should "have an error on ending_production_on" do
            assert_not_nil @step.errors.on(:ending_production_on)  
          end          
        end
      end
      
      context "with date less than begining_production_on" do
        setup do
          @step.begining_production_on = Date.today 
          @step.ending_production_on = Date.today - 6.days
          @step.valid?
        end
        
        should "have an error on ending_production_on" do
          assert_not_nil @step.errors.on(:begining_production_on)  
        end
      end          
    end
    
    context "should be able to build production_progresses with end_product" do
      setup do
        @step.build_production_progresses_with_end_products
        test = "test"
      end
      
      should "have product in production_progresses equal to product in end_product" do
        assert_equal @survey.order.end_products.first, @step.production_progresses.first.product
      end
      
      should "return a goog number of product" do
        assert_equal 1, @step.number_of_products
      end
      
      should "return a goog number of pieces" do
        assert_equal 35, @step.number_of_pieces
      end
      
      context "when production step is saved" do
        setup do
          @step.production_progresses.first.progression = 0
          @step.save!
        end
        
        should "save production_progresses associated" do
          assert !@step.production_progresses.first.new_record?
        end
        
        context "when a production_progress is modified and step is saved again" do
          setup do
            flunk "progression should not be equal to 50" if @step.production_progresses.first.progression.to_i == 50
            @step.production_progresses.first.progression = 50
            @step.save!
          end
          
          should "update production_progress attributes" do 
             assert_equal 50, @step.production_progresses.first.progression
          end
        end
        
      end
    end
  end
end
