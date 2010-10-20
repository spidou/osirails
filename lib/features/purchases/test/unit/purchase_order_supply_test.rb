require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseOrderSupplyTest < ActiveSupport::TestCase
  
  should_have_many :request_order_supplies
  should_have_many :purchase_request_supplies, :through => :request_order_supplies

  should_have_many :purchase_delivery_items
  should_have_many :purchase_deliveries, :through => :purchase_delivery_items
  should_have_one   :issued_purchase_delivery_item
  
  should_belong_to :purchase_order, :supply, :canceller
  
  should_validate_presence_of :supply_id, :supplier_designation, :supplier_reference

  should_validate_numericality_of :quantity, :fob_unit_price
  should_validate_numericality_of :taxes

  context "A new purchase order supply" do
    setup do
      @purchase_order = PurchaseOrder.new
      build_purchase_order_supplies( @purchase_order, { :supplier_reference => "C.01012010",
                                                        :supplier_designation => "First Purchase Order Supply" })
      flunk "should have a new record of purchase order supply" unless (@purchase_order_supply = @purchase_order.purchase_order_supplies.first)
    end
    
    should "not have possibility to be cancelled" do
      assert !@purchase_order_supply.can_be_cancelled?
    end
  end
  
  context "A purchase order supply when purchase order status is draft" do
    setup do
      @purchase_order = create_purchase_order
      flunk "should have a new record of purchase order supply" unless (@purchase_order_supply = @purchase_order.purchase_order_supplies.first)
    end
    
    should "have possibility to be deleted" do
      assert @purchase_order_supply.can_be_deleted?
    end
    
    context "when deleted" do
      setup do
        @purchase_order.purchase_order_supplies.first.should_destroy = 1
        @purchase_order.save!
        @purchase_order.reload
      end
      
      should "purchase_order_supply not appear in purchase_order_supplies collection" do
        assert_nil @purchase_order.purchase_order_supplies.detect(&:should_destroy?)
      end
    end
    
    should "return a good fob unit price including taxes" do
      expected_result = 18  #fob_unit_price * (1 + ( taxes / 100))
                            #     12       * (1 + (    50 / 100))
      assert_equal expected_result, @purchase_order_supply.unit_price_including_tax(@purchase_order, @purchase_order_supply.supply)
    end
    
    should "return a good total price" do
      expected_result = 18000   #quantity * (fob_unit_price * (1 +( taxes / 100)))
                                # => 1000 * ( 12            * (1 +(    50 / 100))) 
      assert_equal expected_result, @purchase_order_supply.purchase_order_supply_total
    end
    
    context "with a purchase request existing for purchase_order" do
      setup do
        @purchase_request = create_purchase_request(:purchase_request_supplies => [{:supply_id => @purchase_order.purchase_order_supplies.first.supply_id,
                                                                                    :expected_quantity => 1000,
                                                                                    :expected_delivery_date => Date.today + 4.week,
                                                                                    :purchase_priority_id => purchase_priorities("first_purchase_priority").id
                                                                                  },
                                                                                  { :supply_id => @purchase_order.purchase_order_supplies.last.supply_id,
                                                                                    :expected_quantity => 2000,
                                                                                    :expected_delivery_date => Date.today + 2.week,
                                                                                    :purchase_priority_id => purchase_priorities("first_purchase_priority").id
                                                                                  }] )
        @purchase_request.save!
        flunk "purchase request should be saved" if @purchase_request.new_record?
        flunk "purchase request supplies should be saved" if @purchase_request.purchase_request_supplies.select(&:new_record?).any?
      end
      
      should "return a good purchase_request_supply for association with purchase_order_supply" do
        assert_equal 1, @purchase_order_supply.unconfirmed_purchase_request_supplies.size
      end
      
      should "NOT have association with purchase_request_supply when purchase_request_supply is not selected" do  
        assert_equal 0, @purchase_order_supply.purchase_request_supplies.size
      end
      
      context "when purchase_request_supply is selected for association with purchase_order_supply" do
        
        setup do
          @purchase_order_supply.purchase_request_supplies_ids = @purchase_request.purchase_request_supplies.first.id.to_s
          @purchase_order.purchase_order_supplies.first.attributes = @purchase_order_supply.attributes
          @purchase_order.save!
        end
        
        should "have purchase_request id when calling get_purchase_request_supplies_ids" do
          assert_match @purchase_request.purchase_request_supplies.first.id.to_s, @purchase_order_supply.get_purchase_request_supplies_ids
        end
        
        should "have association with purchase_request_supply when purchase_order is saved" do 
          assert_equal 1, @purchase_order_supply.purchase_request_supplies.size
        end
        
        context "when deselect association with purchase_request_supply" do
          setup do
            flunk "purchase_order_supply should have association with purchase_request_supply" if @purchase_order_supply.purchase_request_supplies.size == 0
            @purchase_order_supply.purchase_request_supplies_ids = ""
            @purchase_order_supply.purchase_request_supplies_deselected_ids = @purchase_request.purchase_request_supplies.first.id.to_s 
            @purchase_order.purchase_order_supplies.first.attributes = @purchase_order_supply.attributes
            @purchase_order.save!
          end
          
          should "NOT have purchase_request id when calling get_purchase_request_supplies_ids" do
            assert_not_equal @purchase_request.purchase_request_supplies.first.id.to_s, @purchase_order_supply.get_purchase_request_supplies_ids
          end
          
          should "NOT have association with purchase_request_supply when purchase_order is saved" do 
            assert_equal 0, @purchase_order_supply.purchase_request_supplies.size
          end
          
          should "return purchase_request_supply which is deselected when unconfirmed_purchase_request_supplies is using" do
            assert_equal @purchase_order_supply.purchase_request_supplies_deselected_ids.to_i, @purchase_order_supply.unconfirmed_purchase_request_supplies.first.id.to_i
          end
          
        end
      end
      
    end
  end 
  
  context "A purchase order supply when purchase order status is confirmed" do
    setup do
      @purchase_order = create_confirmed_purchase_order
      @purchase_order_supply = @purchase_order.purchase_order_supplies.first
    end
    
    should "NOT be able to be deleted" do
      assert !@purchase_order_supply.can_be_deleted?
    end  
    
    should "be able to be cancelled" do
      assert @purchase_order_supply.can_be_cancelled?
    end
    
    context "which NOT have purchase_delivery associated" do  
      
      should "be untreated" do
        assert @purchase_order_supply.untreated?
      end
      
      should "NOT be processing_by_supplier" do
        assert !@purchase_order_supply.processing_by_supplier?
      end
      
      should "NOT be treated" do
        assert !@purchase_order_supply.treated?
      end 
    end
    
    context "which have not receive purchase_delivery associated with remaining quantity" do
      setup do
        @purchase_delivery = PurchaseDelivery.new
        @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, @purchase_order)
        @purchase_delivery.purchase_delivery_items.first.quantity /= 2 
        @purchase_delivery.save!
      end
      
      teardown do
        @purchase_delivery = nil
        @purchase_order_supply = nil
        @purchase_order = nil
      end
      
      should "be able to be cancelled" do
        assert @purchase_order_supply.can_be_cancelled?
      end
      
      should "NOT be untreated" do
        assert !@purchase_order_supply.untreated?
      end
      
      should "be processing_by_supplier" do
        assert @purchase_order_supply.processing_by_supplier?
      end
      
      should "NOT be treated" do
        assert !@purchase_order_supply.treated?
      end  
      
      should "remain quantity for a new purchase_delivery" do
        assert_equal 500, @purchase_order_supply.remaining_quantity_for_purchase_delivery
      end
      
      should "return a good total quantity" do
        assert_equal 500, @purchase_order_supply.count_quantity_in_purchase_delivery_items
      end
      
      context "which is cancelled" do
        setup do
          @purchase_order_supply.cancelled_comment = "cancelled"
          @purchase_order_supply.cancelled_by_id = users("admin_user").id
          flunk "purchase order supply should be cancel" unless @purchase_order_supply.cancel
        end
        
        should "be cancelled" do
          assert @purchase_order_supply.cancelled?
        end
      
        should "not be able to be cancelled" do
          assert !@purchase_order_supply.can_be_cancelled?
        end
        
        should "put automatically purchase_delivery items status to cancelled" do
          assert @purchase_order_supply.purchase_delivery_items.first.cancelled?
        end
      end
      
      context "when all purchase order supply are cancelled" do
        setup do
          @purchase_order.purchase_order_supplies.each do |purchase_order_supply|
            purchase_order_supply.cancelled_comment = "cancelled"
            purchase_order_supply.cancelled_by_id = users("admin_user").id
            purchase_order_supply.cancel
          end
        end
        
        should "cancel automatically purchase order associated" do
          assert @purchase_order.cancelled?
        end
      end
    end
    
    context "which have not receive purchase_delivery associated withouts remaining quantity" do
      setup do
        @purchase_delivery = PurchaseDelivery.new
        @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, @purchase_order) 
        @purchase_delivery.save!
      end
      
      
      should "be able to be cancelled" do
        assert @purchase_order_supply.can_be_cancelled?
      end
      
      should "NOT be untreated" do
        assert !@purchase_order_supply.untreated?
      end
      
      should "be processing_by_supplier" do
        assert @purchase_order_supply.processing_by_supplier?
      end
      
      should "NOT be treated" do
        assert !@purchase_order_supply.treated?
      end  
      
      should "NOT remain quantity for a new purchase_delivery" do
        assert_equal 0, @purchase_order_supply.remaining_quantity_for_purchase_delivery
      end
      
      should "return a good total quantity" do
        assert_equal 1000, @purchase_order_supply.count_quantity_in_purchase_delivery_items
      end
    end
    
    context "which have a receive purchase_delivery associated with remaining quantity" do
      setup do
        @purchase_delivery = PurchaseDelivery.new
        @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, @purchase_order) 
        @purchase_delivery.purchase_delivery_items.first.quantity /= 2 
        @purchase_delivery = put_received_status_for(@purchase_delivery)
      end
      
      should "NOT be able to be cancelled" do
        assert !@purchase_order_supply.can_be_cancelled?
      end
      
      should "NOT be untreated" do
        assert !@purchase_order_supply.untreated?
      end
      
      should "be processing_by_supplier" do
        assert @purchase_order_supply.processing_by_supplier?
      end
      
      should "NOT be treated" do
        assert !@purchase_order_supply.treated?
      end  
      
      should "remain quantity for a new purchase_delivery" do
        assert_equal 500, @purchase_order_supply.remaining_quantity_for_purchase_delivery
      end
      
      should "return a good total quantity" do
        assert_equal 500, @purchase_order_supply.count_quantity_in_purchase_delivery_items
      end
    end
    
    context "which have a receive purchase_delivery associated without remaining quantity" do
      setup do
        @purchase_delivery = PurchaseDelivery.new
        @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, @purchase_order)
        @purchase_delivery = put_received_status_for(@purchase_delivery)
      end
      
      should "have return false when 'not_receive_associated_purchase_deliveries?' is called" do
        assert !@purchase_order_supply.not_receive_associated_purchase_deliveries?
      end
      
      should "return true when 'verify_all_purchase_delivery_items_are_received?' is called" do
        assert @purchase_order_supply.verify_all_purchase_delivery_items_are_received?
      end
      
      should "NOT be able to be cancelled" do
        assert !@purchase_order_supply.can_be_cancelled?
      end
      
      should "NOT be untreated" do
        assert !@purchase_order_supply.untreated?
      end
      
      should "NOT be processing_by_supplier" do
        assert !@purchase_order_supply.processing_by_supplier?
      end
      
      should "be treated" do
        assert @purchase_order_supply.treated?
      end  
      
      should "NOT remain quantity for a new purchase_delivery" do
        assert_equal 0, @purchase_order_supply.remaining_quantity_for_purchase_delivery
      end
      
      should "return a good total quantity" do
        assert_equal 1000, @purchase_order_supply.count_quantity_in_purchase_delivery_items
      end
      
      context "when purchase_delivery_item is reported and issued_purchase_order_supply is cancelled" do
        
        setup do
          @issue_purchase_order_supply = create_purchase_order_supply_reported_for(@purchase_delivery.purchase_delivery_items.first).reload
          @issue_purchase_order_supply.cancelled_by_id = users("admin_user").id
          @issue_purchase_order_supply.cancelled_comment = "cancelled issue_purchase_order_supply"
          @purchase_delivery.reload
          flunk "issue_purchase_order_supply_should be cancelled" unless @issue_purchase_order_supply.cancel
        end
        
        should "NOT able to be cancel" do
          assert !@issue_purchase_order_supply.can_be_cancelled?
        end
        
        should "be able to nulify 'issued_at' in purchase_delivery item associated" do
          assert_nil @purchase_delivery.purchase_delivery_items.first.issued_at
        end
        
        should "be able to nulify 'issue_purchase_order_supply_id' in purchase_delivery item associated" do
          assert_nil @purchase_delivery.purchase_delivery_items.first.issue_purchase_order_supply_id
        end
      end
    end
  end
  
  context 'A "purchase_order_supply" with associated with a draft "purchase_order" while cancellation' do
    setup do
      @purchase_order = create_purchase_order
      @purchase_order.purchase_order_supplies.first.cancelled_at = Time.now
    end
    
    subject { @purchase_order.purchase_order_supplies.first }
    
    should_validate_presence_of :cancelled_by_id, :cancelled_comment
  end
end
