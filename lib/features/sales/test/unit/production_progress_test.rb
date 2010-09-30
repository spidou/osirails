require File.dirname(__FILE__) + '/../sales_test' 

class ProductionProgressTest < ActiveSupport::TestCase
  should_belong_to  :product
  should_belong_to  :production_step
  
  context "a new production_progress" do
    setup do
      @production_progress = ProductionProgress.new
    end
  
    context "associated with a end_product" do
      setup do
        @end_product = create_default_end_product
        @production_progress.product_id = @end_product.id
        flunk "quantity of end_product should be equal to 1" unless @end_product.quantity == 1
      end
      
      context "when global quantity is setting to 100" do
        setup do
          @production_progress.progression = 100
        end
      
        context "and built_quantity is less than quantity" do
          setup do
            @production_progress.built_quantity = 0
            @production_progress.valid?
          end
          should "have an error on progression" do
            assert_not_nil @production_progress.errors.on(:progression)
          end
        
        context "and built_quantity is equal to quantity" do
          setup do
            @production_progress.built_quantity = 1
            @production_progress.available_to_deliver_quantity = 1
            @production_progress.valid?
          end
          should "Not have an error on progression" do
            assert_nil @production_progress.errors.on(:progression)
          end
        end
      
      context "and available_to_deliver_quantity is less than quantity" do
        setup do
          @production_progress.available_to_deliver_quantity = 0
          @production_progress.valid?
        end
        should "have an error on progression" do
          assert_not_nil @production_progress.errors.on(:progression)
        end  
      end
      context "and available_to_deliver_quantity is equal to quantity" do
        setup do
          @production_progress.available_to_deliver_quantity = 1
          @production_progress.built_quantity = 1
          @production_progress.valid?
        end
        should "Not have an error on progression" do
          assert_nil @production_progress.errors.on(:progression)
        end
      end
    end
  end
      context "with a progression" do
        context "less than 0" do
          setup do
            @production_progress.progression = -55
            @production_progress.valid?
          end
          
          should "have an error on progression" do
            assert_not_nil @production_progress.errors.on(:progression)
          end
        end
        context "greater than 100" do
          setup do
            @production_progress.progression = 555
            @production_progress.valid?
          end
          
          should "have an error on progression" do
            assert_not_nil @production_progress.errors.on(:progression)
          end
        end
        context "between 0 to 100" do
          setup do
            @production_progress.progression = 55
            @production_progress.valid?
          end
          
          should "Not have an error on progression" do
            assert_nil @production_progress.errors.on(:progression)
          end
        end
      end
      
      context "with a good building_quantity" do
        setup do
          @production_progress.building_quantity = 1
          @production_progress.valid?
        end
        
        should "Not have an error on building_quantity" do
          assert_nil @production_progress.errors.on(:building_quantity)
        end
      end
      context "with a bad building_quantity" do
        setup do
          @production_progress.building_quantity = 3
          @production_progress.valid?
        end
        
        should "Have an error on building_quantity" do
          assert_match /building quantity should be between 0 and/, @production_progress.errors.on(:building_quantity)
        end
      end
      
      context "with a good built_quantity" do
        setup do
          @production_progress.built_quantity = 1
          @production_progress.valid?
        end
        
        should "Not have an error on built_quantity" do
          assert_nil @production_progress.errors.on(:built_quantity)
        end
      end
      
      context "with a built_quantity greater_than product quantity" do
        setup do
          @production_progress.built_quantity = 3
          @production_progress.valid?
        end
        
        should "Have an error on built_quantity" do
          assert_match /built quantity should be between/, @production_progress.errors.on(:built_quantity)
        end
      end
      
      context "with a building_quantity and a built_quantity which sum greater_than product quantity" do
        setup do
          @production_progress.building_quantity = 1
          @production_progress.built_quantity = 1
          @production_progress.valid?
        end
        
        should "Have an error on building_quantity" do
          assert_match /built quantity should be between/, @production_progress.errors.on(:built_quantity)
        end
      end
      
      context "with a good available_to_deliver_quantity" do
        setup do
          @production_progress.available_to_deliver_quantity = 1
          @production_progress.built_quantity = 1
          @production_progress.valid?
        end
        
        should "Not have an error on available_to_deliver_quantity" do
          assert_nil @production_progress.errors.on(:available_to_deliver_quantity)
        end
      end
      
      context "with a available_to_deliver_quantity greater_than built_quantity" do
        setup do
          @production_progress.built_quantity = 1
          @production_progress.available_to_deliver_quantity = 5
          @production_progress.valid?
        end
        
        should "Have an error on available_to_deliver_quantity" do
          assert_match /available_to_deliver_quantity should be between 0 and/, @production_progress.errors.on(:available_to_deliver_quantity)
        end
      end
    end
  end
end
