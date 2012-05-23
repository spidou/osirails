require File.dirname(__FILE__) + '/../logistics_test'

class SupplierSupplyTest < ActiveSupport::TestCase
  should_belong_to :supply, :supplier
  
  should_validate_numericality_of :fob_unit_price, :taxes, :lead_time
  
  should_journalize :attributes        => [:supplier_id, :supplier_reference, :lead_time, :fob_unit_price, :taxes]
                    #:identifier_method => Proc.new{ |s| "#{s.supplier.name}" }
  
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
    
    context "with fob_unit_price and taxes" do
      setup do
        @supplier_supply.fob_unit_price = 100
      end
      
      context "but without taxes" do
        should "have a unit_price equal to its fob_unit_price" do
          assert_equal @supplier_supply.fob_unit_price, @supplier_supply.unit_price
        end
      end
      
      context "with taxes" do
        setup do
          @supplier_supply.taxes = 10
        end
        
        should "have a valid unit_price" do
          expected_value = 110 # fob_unit_price * ( 1 + ( taxes / 100 ) ) <=> 100 * ( 1 + ( 10 / 100 ) ) = 110
          assert_equal expected_value, @supplier_supply.unit_price
        end
      end
    end
  end
end
