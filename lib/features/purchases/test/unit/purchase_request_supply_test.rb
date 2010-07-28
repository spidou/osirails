require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseRequestSupplyTest < ActiveSupport::TestCase
  
  should_have_many  :request_order_supplies
  should_have_many  :purchase_order_supplies, :through => :request_order_supplies
  
  should_have_one   :confirmed_purchase_order_supply, :through => :request_order_supplies
  should_have_many  :draft_purchase_order_supplies, :through => :request_order_supplies
  should_belong_to :purchase_request, :supply
  
  should_validate_presence_of :supply_id
  #TODO should_validate_persistence_of :expected_delivery_date
  
  should_validate_numericality_of :expected_quantity
  #TODO should_validate_date :expected_delivery_date, :after => Date.today
  
  context "a purchase request supply" do
    setup do
      @purchase_request = create_purchase_request
      @purchase_request_supply = @purchase_request.purchase_request_supplies.first
    end
    
    context "which is not cancelled" do
      
      should "not be cancelled" do
        assert !@purchase_request_supply.cancelled?
      end
      should "be able to be cancelled" do
        assert @purchase_request_supply.can_be_cancelled?
      end
    end
    
    context "which not have purchase order associated" do
      
      should "not be in during treatment status" do
        assert !@purchase_request_supply.during_treatment?
      end
      
      should "not be in treated status" do
        assert !@purchase_request_supply.treated?
      end
      
      should "be in untreated status" do
        assert @purchase_request_supply.untreated?
      end
      
      should "be include in all pending purchase request supplies" do
        assert PurchaseRequestSupply.get_all_pending_purchase_request_supplies.select{|n| n.id == @purchase_request_supply.id}.any?
      end
        
    end
    
    context "which have purchase order associated" do
      
      context "which is in confirmed status" do
        
        setup do
          create_association_with_purchase_order_confirmed(@purchase_request_supply) 
        end
        
        should "be in treated status" do
          assert @purchase_request_supply.treated?
        end
        
        should "not be in during treatment status" do
          assert !@purchase_request_supply.during_treatment?
        end
        
        should "not be in untreated status" do
          assert !@purchase_request_supply.untreated?
        end
        
        should "not be include in all pending purchase request supplies" do
          assert PurchaseRequestSupply.get_all_pending_purchase_request_supplies.select{|n| n.id == @purchase_request_supply.id}.empty?
        end
        
      end
            
      context "which is in draft status" do
        
        setup do
          create_association_with_purchase_order_draft(@purchase_request_supply) 
        end
        
        should "be in during treatment status" do
          assert @purchase_request_supply.during_treatment?
        end
        
        should "not be in treated status" do
          assert !@purchase_request_supply.treated?
        end
        
        should "not be in untreated status" do
          assert !@purchase_request_supply.untreated?
        end
        
        should "be include in all pending purchase request supplies" do
          assert PurchaseRequestSupply.get_all_pending_purchase_request_supplies.select{|n| n.id == @purchase_request_supply.id}.any?
        end
        
      end  
    end
  
    context "which is cancelled" do
      
        setup do
          @purchase_request_supply = cancelled_purchase_request_supply(@purchase_request_supply)
        end
       
        should "be cancelled" do
          assert @purchase_request_supply.cancelled?
        end
        
        should "not be able to be cancelled" do
          assert !@purchase_request_supply.can_be_cancelled?
        end
        
        should "not be include in all pending purchase request supplies" do
          assert PurchaseRequestSupply.get_all_pending_purchase_request_supplies.select{|n| n.id == @purchase_request_supply.id}.empty?
        end 
    end
  end
end
