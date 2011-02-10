module StockFlowTest
  class << self
    def included base
      base.class_eval do
        
        #TODO
        # current_stock_value
        # current_stock_quantity
        
        should_belong_to :supply, :inventory
        
        should_validate_presence_of :supply, :with_foreign_key => :default
        should_validate_presence_of :identifier
        
        should_validate_numericality_of :quantity
        
        #TODO
        #validates_persistence_of :supply_id, :identifier, :unit_price, :quantity, :previous_stock_value, :previous_stock_quantity
        
        should "NOT be from_inventory" do
          assert !@stock_flow.from_inventory?
        end
        
        context "associated to a supply" do
          setup do
            @supply = create_default_supply
            flunk "@supply should NOT have any stock_flows" if @supply.stock_flows.any?
            
            @stock_flow.supply = @supply
          end
          
          subject{ @stock_flow }
          
          # this shoulda test fails because previous_stock_value and previous_stock_quantity are setup automatically before validation
          #should_validate_numericality_of :unit_price, :previous_stock_value, :previous_stock_quantity
          
          should "NOT have previous_stock_quantity" do
            assert_nil @stock_flow.previous_stock_quantity
          end
          
          should "NOT have previous_stock_value" do
            assert_nil @stock_flow.previous_stock_value
          end
          
          should "automatically set up previous_stock_value before validation" do
            @stock_flow.valid?
            assert_equal 0.0, @stock_flow.previous_stock_value
          end
          
          should "automatically set up previous_stock_quantity before validation" do
            @stock_flow.valid?
            assert_equal 0, @stock_flow.previous_stock_quantity
          end
          
          context "which has stock_value > 0 and stock_quantity > 0" do
            setup do
              create_stock_input_for_supply(@supply, :sleep_delay => true)
              flunk "@supply should have a stock_value at 10000.0\nbut was #{@supply.stock_value}" if @supply.stock_value != 10000.0
              flunk "@supply should have a stock_quantity at 100\nbut was #{@supply.stock_quantity}" if @supply.stock_quantity != 100
            end
            
            should "automatically set up previous_stock_value before validation" do
              @stock_flow.valid?
              assert_equal 10000.0, @stock_flow.previous_stock_value
            end
            
            should "automatically set up previous_stock_quantity before validation" do
              @stock_flow.valid?
              assert_equal 100, @stock_flow.previous_stock_quantity
            end
          end
        end
        
        context "associated to a disabled supply" do
          setup do
            @supply = create_default_supply
            create_stock_input_for_supply(@supply, :sleep_delay => true)
            create_stock_output_to_set_stock_quantity_at_zero_for_supply(@supply)
            disable_supply(@supply)
            
            @stock_flow.supply_id = @supply.id
            @stock_flow.valid?
          end
          
          should "be invalid" do
            assert_match /est désactivé/, @stock_flow.errors.on(:supply)
          end
        end
        
        context "with flag 'from_inventory' at true" do
          setup do
            @stock_flow.from_inventory = true
          end
          
          should "be from_inventory" do
            assert @stock_flow.from_inventory?
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
          
          should "be from_inventory" do
            assert @stock_flow.from_inventory?
          end
        end
        
        context "which is saved (and associated to an inventory)" do
          setup do
            @supply = create_default_supply
            flunk "@supply should NOT have any stock_flows" if @supply.stock_flows.any?
            
            @inventory = create_inventory_with( { @supply => 100 } )
            flunk "@inventory should have 1 stock_flow\nbut has #{@inventory.stock_flows.count}" unless @inventory.stock_flows.count == 1
            
            @stock_flow = @inventory.stock_flows.first
            flunk "@stock_flow should NOT be a new record" if @stock_flow.new_record?
          end
        end
        
      end
    end
  end
end
