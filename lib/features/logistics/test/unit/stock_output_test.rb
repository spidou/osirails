require File.dirname(__FILE__) + '/../logistics_test'

class StockOutputTest < ActiveSupport::TestCase
  #TOOD
  #has_permissions :as_business_object
  
  context "A stock_output" do
    setup do
      @stock_flow = StockOutput.new
    end
    teardown do
      @stock_flow = nil
    end
    
    subject{ @stock_flow }
    
    include StockFlowTest
    
    should "have a valid calculation_method" do
      assert_equal :-, @stock_flow.calculation_method
    end
    
    context "which is saved" do
      setup do
        @supply = create_default_supply
        create_stock_input_for_supply(@supply, :sleep_delay => true)
        
        flunk "@supply should have a stock_value at 10000.0\nbut was #{@supply.stock_value}" if @supply.stock_value != 10000.0
        flunk "@supply should have a stock_quantity at 100\nbut was #{@supply.stock_quantity}" if @supply.stock_quantity != 100
        flunk "@supply should have a average_unit_stock_value at 100.0\nbut was #{@supply.average_unit_stock_value}" if @supply.average_unit_stock_value != 100.0
        
        @stock_flow.attributes = { :supply_id   => @supply.id,
                                   :identifier  => "123456789",
                                   :quantity    => 10 }
        @stock_flow.save!
      end
      
      should "NOT be editable" do
        assert !@stock_flow.can_be_edited?
      end
      
      should "NOT be edited" do
        assert !@stock_flow.update_attribute(:quantity, @stock_flow.quantity + 10)
        assert !@stock_flow.update_attributes(:quantity => @stock_flow.quantity + 20)
        
        @stock_flow.quantity += 30
        assert !@stock_flow.save
      end
      
      should "NOT be destroyable" do
        assert !@stock_flow.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@stock_flow.destroy
      end
      
      should "have a valid unit_price" do
        expected_value = 100 # supply.average_unit_stock_value
        assert_equal expected_value, @stock_flow.unit_price
      end
      
      should "have a valid current_stock_value" do
        expected_value = BigDecimal.new("9000") # previous_stock_value - ( unit_price * quantity ) <=> 10000 - (100 * 10) <=> 10000 - 1000 <=> 9000
        assert_equal expected_value, @stock_flow.current_stock_value
      end
      
      should "have a valid current_stock_quantity" do
        expected_value = 90 # previous_stock_quantity - quantity <=> 100 - 10 <=> 90
        assert_equal expected_value, @stock_flow.current_stock_quantity
      end
    end
    
    context "associated to a supply" do
      setup do
        @supply = create_default_supply
        flunk "@supply should NOT have any stock_flows" if @supply.stock_flows.any?
        
        @stock_flow.supply = @supply
      end
      
      should "automatically set up unit_price before validation" do
        @stock_flow.valid?
        assert_not_nil @stock_flow.unit_price
      end
      
      context "which has stock_value > 0 and stock_quantity > 0" do
        setup do
          create_stock_input_for_supply(@supply, :sleep_delay => true)
          flunk "@supply should have a stock_quantity at 100\nbut was #{@supply.stock_quantity}" if @supply.stock_quantity != 100
        end
        
        should "NOT allow a quantity greater than the supply's stock_quantity" do
          [101, 200, 1000].each do |q|
            @stock_flow.quantity = q
            @stock_flow.valid?
            
            assert_match /La quantité choisie est supérieure au stock disponible pour cet article/, @stock_flow.errors.on(:quantity)
          end
        end
        
        should "allow a quantity equal to the supply's stock_quantity" do
          @stock_flow.quantity = 100
          @stock_flow.valid?
          
          assert_nil @stock_flow.errors.on(:quantity)
        end
        
        should "allow a quantity less than the supply's stock_quantity" do
          [1, 50, 99].each do |q|
            @stock_flow.quantity = q
            @stock_flow.valid?
            
            assert_nil @stock_flow.errors.on(:quantity)
          end
        end
      end
    end
    
    context "associated to a supply and to an inventory" do
      setup do
        @supply = create_default_supply
        flunk "@supply should NOT have any stock_flows" if @supply.stock_flows.any?
        
        @inventory = build_inventory_with( { @supply => 100 } )
        flunk "@inventory should have 1 stock_flow\nbut has #{@inventory.stock_inputs.size}" unless @inventory.stock_inputs.size == 1
        
        @stock_flow = @inventory.stock_inputs.first
        flunk "@stock_flow should exist" unless @stock_flow
      end
      
      should "automatically set up unit_price before validation" do
        @stock_flow.valid?
        assert_not_nil @stock_flow.unit_price
      end
    end
  end
end
