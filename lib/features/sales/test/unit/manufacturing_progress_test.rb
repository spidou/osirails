require File.dirname(__FILE__) + '/../sales_test'

class ManufacturingProgressTest < ActiveSupport::TestCase
  should_belong_to :end_product, :manufacturing_step
  
  should_validate_presence_of :manufacturing_step, :end_product, :with_foreign_key => :default
  
  should_validate_numericality_of :progression, :building_quantity, :built_quantity, :available_to_deliver_quantity
  
  #TODO validate :progression between 0 to 100
  #TODO validate :building_quantity, :built_quantity, :available_to_deliver_quantity > 0
  
  context "Associated to an end_product, a manufacturing_progress" do
    setup do
      @order = create_default_order
      @manufacturing_step = @order.production_step.manufacturing_step
      
      @end_product = create_default_end_product(@order, :quantity => 10)
      flunk "@end_product.quantity should be equal to 10" unless @end_product.quantity == 10
      
      @mp = @manufacturing_step.manufacturing_progresses.build(:end_product_id => @end_product.id)
    end
    
    should "have default progression at 0" do
      assert_equal 0, @mp.progression
    end
    
    should "have default building_quantity at 0" do
      assert_equal 0, @mp.building_quantity
    end
    
    should "have default built_quantity at 0" do
      assert_equal 0, @mp.built_quantity
    end
    
    should "have default available_to_deliver_quantity at 0" do
      assert_equal 0, @mp.available_to_deliver_quantity
    end
    
    should "have building_remaining_quantity at 10" do
      assert_equal 10, @mp.building_remaining_quantity
    end
    
    should "have built_remaining_quantity at 10" do
      assert_equal 10, @mp.built_remaining_quantity
    end
    
    should "have range_for_building_quantity at '0..10'" do
      assert_equal 0..10, @mp.range_for_building_quantity
    end
    
    should "have range_for_built_quantity at '0..10'" do
      assert_equal 0..10, @mp.range_for_built_quantity
    end
    
    should "have range_for_available_to_deliver_quantity at '0..0'" do
      assert_equal 0..0, @mp.range_for_available_to_deliver_quantity
    end
    
    context "with a building_quantity at 3" do
      setup do
        @mp.building_quantity = 3
      end
      
      should "have built_remaining_quantity at 7" do
        assert_equal 7, @mp.built_remaining_quantity
      end
      
      should "have range_for_built_quantity at '0..7'" do
        assert_equal 0..7, @mp.range_for_built_quantity
      end
    end
    
    context "with a built_quantity at 3" do
      setup do
        @mp.built_quantity = 3
      end
      
      should "have building_remaining_quantity at 7" do
        assert_equal 7, @mp.building_remaining_quantity
      end
      
      should "have range_for_building_quantity at '0..7'" do
        assert_equal 0..7, @mp.range_for_building_quantity
      end
      
      should "have range_for_available_to_deliver_quantity at '0..3'" do
        assert_equal 0..3, @mp.range_for_available_to_deliver_quantity
      end
    end
    
    # test validates_sum_of_building_quantity_and_build_quantity
    context "with the sum of its building_quantity and built_quantity is greater than product quantity" do
      setup do
        @mp.building_quantity = 6
        @mp.built_quantity = 6
        # assuming 6 + 6 = 12 > 10
        
        @mp.valid?
      end
      
      should "have invalid building_quantity" do
        assert_match /Sum of 'building' and 'build' products must be between 0 and 10/, @mp.errors.on(:building_quantity)
      end
      
      should "have invalid built_quantity" do
        assert_match /Sum of 'building' and 'build' products must be between 0 and 10/, @mp.errors.on(:built_quantity)
      end
    end
    
    # test validates_sum_of_building_quantity_and_build_quantity
    context "with the sum of its building_quantity and built_quantity is less than 0" do
      setup do
        @mp.building_quantity = 2
        @mp.built_quantity = -6
        # assuming 2 - 6 = -4 < 0
        
        @mp.valid?
      end
      
      should "have invalid building_quantity" do
        # we use include? because the attribute should have 2 errors (because it's less than 0)
        assert @mp.errors.on(:building_quantity).include?("Sum of 'building' and 'build' products must be between 0 and 10"), @mp.errors.on(:building_quantity).inspect
      end
      
      should "have invalid built_quantity" do
        # we use include? because the attribute should have 2 errors (because it's less than 0)
        assert @mp.errors.on(:built_quantity).include?("Sum of 'building' and 'build' products must be between 0 and 10"), @mp.errors.on(:built_quantity).inspect
      end
    end
    
    # test validates_progression
    context "with a built_quantity equal to product quantity" do
      setup do
        @mp.built_quantity = 10
      end
      
      context "and progression not set at maximum" do
        setup do
          @mp.valid?
          flunk "@mp.progression should not be at maximum" if @mp.progression_max?
        end
        
        should "have an invalid progression" do
          assert_match /have to be at 100% if all products are finished/, @mp.errors.on(:progression)
        end
      end
      
      context "and progression set at maximum" do
        setup do
          @mp.progression = 100
          @mp.valid?
        end
        
        should "have a valid progression" do
          assert_nil @mp.errors.on(:progression)
        end
      end
    end
    
    # test validates_progression, progression_max?
    context "with a progression equal to 100" do
      setup do
        @mp.progression = 100
      end
      
      should "have a progression_max" do
        assert @mp.progression_max?
      end
      
      context "and built_quantity less that product quantity" do
        setup do
          @mp.built_quantity = 9
          @mp.valid?
        end
        
        should "have an invalid progression" do
          assert_match /cannot be at 100% if all products are not finished/, @mp.errors.on(:progression)
        end
      end
      
      context "and built_quantity equal to product quantity" do
        setup do
          @mp.built_quantity = 10
          @mp.valid?
        end
        
        should "have a valid progression" do
          assert_nil @mp.errors.on(:progression)
        end
      end
    end
    
    # test progression_max?
    [0, 50, 99, 101, 200].each do |progression|
      context "with a progression at #{progression}" do
        setup do
          @mp.progression = progression
        end
        
        should "NOT have a progression_max" do
          assert !@mp.progression_max?
        end
      end
    end
  end
end
