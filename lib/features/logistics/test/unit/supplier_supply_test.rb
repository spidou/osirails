require File.dirname(__FILE__) + '/../logistics_test'

class SupplierSupplyTest < ActiveSupport::TestCase
  #TODO
  # has_permissions :as_business_object
  
  should_belong_to :supply, :supplier
  
  should_validate_uniqueness_of :supplier_id, :scoped_to => :supply_id
  
  should_validate_numericality_of :fob_unit_price, :taxes, :lead_time
  
  #TODO
  # validates_persistence_of :supply_id
  
  context "A supplier_supply" do
    setup do
      @supplier_supply = SupplierSupply.new
    end
    
    context "without a supplier" do
      should "be marked to be destroyed" do
        assert @supplier_supply.should_destroy?
      end
    end
    
    context "with a supplier" do
      setup do
        @supplier_supply.supplier = thirds(:first_supplier)
      end
      
      subject{ @supplier_supply }
      
      #TODO
      # validates_persistence_of :supplier_id
      
      context "with should_destroy at 1" do
        setup do
          @supplier_supply.should_destroy = 1
        end
        
        should "be marked to be destroyed" do
          assert @supplier_supply.should_destroy?
        end
      end
    end
    
    context "with fob_unit_price" do
      setup do
        @supplier_supply.fob_unit_price = 100
      end
      
      context "and without taxes" do
        should "have a unit_price equal to its fob_unit_price" do
          assert_equal @supplier_supply.fob_unit_price, @supplier_supply.unit_price
        end
      end
      
      context "and with taxes" do
        setup do
          @supplier_supply.taxes = 10
        end
        
        should "have a valid unit_price" do
          expected_value = 110 # fob_unit_price * ( 1 + ( taxes / 100 ) ) <=> 100 * ( 1 + ( 10 / 100 ) ) = 110
          assert_equal expected_value, @supplier_supply.unit_price
        end
        
        should "have a nil fob_measure_price" do
          assert_nil @supplier_supply.fob_measure_price
        end
        
        should "have a nil measure_price" do
          assert_nil @supplier_supply.measure_price
        end
        
        context "and with a supply which have a measure" do
          setup do
            @commodity_category = CommodityCategory.create! :name => "CommodityCategory For SupplierSupply"
            @commodity_sub_category = CommoditySubCategory.create! :reference => "C.00.00", :supply_category_id => @commodity_category.id, :name => "CommoditySubCategory For SupplierSupply"
            @commodity = Commodity.create! :reference => "C.00.00.00", :name => "Commodity For SupplierSupply", :supply_sub_category_id => @commodity_sub_category.id, :measure => 1.60
            @supplier_supply.supply_id = @commodity.id
            @supplier_supply.fob_unit_price = 12
            @supplier_supply[:reference] = "SR.124578124"
            @supplier_supply.save!
          end
          
          should "have a valid fob_measure_price" do
            # fob_unit_price / supply.measure
            assert_equal 7.5, @supplier_supply.fob_measure_price
          end
          
          should "have a valid measure_price" do
            # unit_price / supply.measure
            assert_equal 8.25, @supplier_supply.measure_price
          end
        end
      end
    end
  end
end
