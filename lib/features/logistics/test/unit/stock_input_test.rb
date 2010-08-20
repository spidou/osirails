require File.dirname(__FILE__) + '/../logistics_test'

class StockInputTest < ActiveSupport::TestCase
  #TODO
  #has_permissions :as_business_object
  
  context "A stock_input" do
    setup do
      @stock_flow = StockInput.new
    end
    teardown do
      @stock_flow = nil
    end
    
    subject{ @stock_flow }
    
    include StockFlowTest
    
    should "have a valid calculation_method" do
      assert_equal :+, @stock_flow.calculation_method
    end
    
    context "which is saved" do
      setup do
        @supply = Supply.first
        flunk "@supply should NOT have any stock_flows" if @supply.stock_flows.any?
        
        @stock_flow.attributes = { :supply_id   => @supply.id,
                                   :identifier  => "123456789",
                                   :unit_price  => 100,
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
      
      should "have a valid current_stock_value" do
        expected_value = 1000.0 # previous_stock_value + ( unit_price * quantity ) <=> 0 + (100 * 10) <=> 1000
        assert_equal expected_value, @stock_flow.current_stock_value
      end
      
      should "have a valid current_stock_quantity" do
        expected_value = 10 # previous_stock_quantity + quantity <=> 0 + 10 <=> 10
        assert_equal expected_value, @stock_flow.current_stock_quantity
      end
    end
    
    context "associated to a supply and to an inventory" do
      setup do
        @supply = Supply.first
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
