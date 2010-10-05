require File.dirname(__FILE__) + '/../purchases_test'

class QuotationSupplyTest < ActiveSupport::TestCase
  should_have_many :quotation_purchase_request_supplies
  should_have_many :purchase_request_supplies
  
  should_belong_to :quotation, :supply
  
  should_validate_presence_of :supplier_designation
  
  context 'A quotation_supply in a new quotation' do
    setup do
      @quotation = Quotation.new
      @quotation_supply = @quotation.quotation_supplies.build
      flunk 'Failed to build the quotation_supply' unless @quotation_supply
      
    end
  end
  
  context 'A quotation_supply in a drafted quotation' do
    setup do
      @quotation = prepare_quotation_for_quotation_supply_test
    end
    
    context 'if is an existing supply' do
      setup do
        @quotation.quotation_supplies.build(:supply_id => supplies("first_commodity").id,
                                            :quantity => 1000,
                                            :taxes => 20,
                                            :unit_price => 15,
                                            :prizegiving => 0,
                                            :designation => supplies("first_commodity").designation,
                                            :supplier_reference => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_reference ,
                                            :supplier_designation => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_designation )
        flunk 'Failed to build the quotation_supply' unless @quotation.quotation_supplies.size == 1
        @quotation_supply = @quotation.quotation_supplies.first
        @quotation.save!
        flunk 'Failed to draft the quotation' unless @quotation.was_drafted?
        @product = @quotation_supply
      end
      
      should 'have an existing supply associated' do
        assert @quotation_supply.existing_supply?
      end
      
      should 'be able to be destroyed' do
        assert @quotation_supply.can_be_destroyed?
      end
      
      should 'be able to be edited' do
        assert @quotation_supply.can_be_edited?
      end
      
      should 'be destroyed successfully' do
        assert @quotation_supply.destroy
      end
      
      include ProductBaseTest
      
      context 'and the quotation_supply is destroyed' do
        setup do
           @quotation_supply.destroy
        end
        
        should 'NOT have quotation_supplies anymore' do
          assert @quotation.quotation_supplies(true).empty?
        end
      end
    end
    
    context 'if is a free supply' do
      setup do
        @quotation.quotation_supplies.build(:quantity => 1000,
                                            :taxes => 20,
                                            :unit_price => 15,
                                            :prizegiving => 0,
                                            :designation => supplies("first_commodity").designation,
                                            :supplier_reference => "159357852",
                                            :supplier_designation => "Designation For Free Supply" )
        flunk 'Failed to build the quotation_supply' unless @quotation.quotation_supplies.size == 1
        @quotation_supply = @quotation.quotation_supplies.first
        @quotation.save!
        flunk 'Failed to draft the quotation' unless @quotation.was_drafted?
      end
      
      should 'have a free supply associated' do
        assert @quotation_supply.free_supply?
      end
      
      should 'be able to be destroyed' do
        assert @quotation_supply.can_be_destroyed?
      end
      
      should 'be destroyed successfully' do
        assert @quotation_supply.destroy
      end
    end
  end
    
  context 'A quotation_supply in a signed quotation' do
    setup do
      @quotation = create_signed_quotation
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
  end
  
  context 'A quotation_supply in a sent quotation' do
    setup do
      @quotation = create_sent_quotation
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
  end
  
  context 'A quotation_supply in a cancelled quotation' do
    setup do
      @quotation = create_cancelled_quotation
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
  end
end
