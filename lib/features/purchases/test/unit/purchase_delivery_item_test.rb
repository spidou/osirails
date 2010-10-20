require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseDeliveryItemTest < ActiveSupport::TestCase
  
  should_belong_to :purchase_delivery, :purchase_order_supply, :issue_purchase_order_supply
  
  should_validate_presence_of :purchase_order_supply_id
  should_validate_numericality_of :quantity
  
  context "A new purchase_delivery item" do
    
    setup do
      @purchase_delivery = PurchaseDelivery.new
      @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, nil)
    end
    
    should "have a valid quantity" do
      @purchase_delivery.valid?
      assert !@purchase_delivery.purchase_delivery_items.first.errors.invalid?(:quantity)
    end
    
    should "have a good total price" do
      expected_result = 18000   #quantity * (fob_unit_price * (1 *( taxes / 100)))
                                # => 1000 * ( 12            * (1 *(    50 / 100))) 
      assert_equal expected_result, @purchase_delivery.purchase_delivery_items.first.purchase_delivery_item_total
    end
    
    context "which have a invalid quantity" do
      setup do
        @purchase_delivery.purchase_delivery_items.first.quantity *= @purchase_delivery.purchase_delivery_items.first.quantity 
      end
      
      should "through a validity error" do
        @purchase_delivery.valid?
        assert_match /n'est pas valide/, @purchase_delivery.purchase_delivery_items.first.errors.on(:quantity)
      end
    end
    
    should "be able to be save" do
      @purchase_delivery.save!
      assert @purchase_delivery.purchase_delivery_items.select(&:new_record?).empty?
    end
  end 
  
  context "A purchase_delivery item" do
    setup do
      @purchase_delivery = PurchaseDelivery.new
      @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, nil)
      @purchase_delivery.save!
    end
      
    context "which have a not received associated purchase_delivery" do
        
      should "not be cancelled" do
        assert !@purchase_delivery.purchase_delivery_items.first.cancelled?
      end
        
      should "be able to be cancelled" do
        assert @purchase_delivery.purchase_delivery_items.first.can_be_cancelled?
      end
        
      should "return true if you cancel it" do
        @purchase_delivery.purchase_delivery_items.first.cancelled_comment = "cancelled purchase_delivery item"
        assert @purchase_delivery.purchase_delivery_items.first.cancel   
      end
    end  
      
    context "which have a received associated purchase_delivery" do
        
      setup do
        @purchase_delivery = put_received_status_for(@purchase_delivery)
      end
        
      should "not have possibility to be cancelled" do
        assert !@purchase_delivery.purchase_delivery_items.first.can_be_cancelled?
      end
      
      should "have possibility to be reported" do
        assert @purchase_delivery.purchase_delivery_items.first.can_be_reported?
      end
      
      should "be reported with a good quantity" do
        @purchase_delivery.purchase_delivery_items.first.issues_comment = "purchase_delivery item issues comment"
        @purchase_delivery.purchase_delivery_items.first.issues_quantity = 100
        assert @purchase_delivery.purchase_delivery_items.first.report
      end
      
      should "not be reported with a bad quantity" do
        @purchase_delivery.purchase_delivery_items.first.issues_comment = "purchase_delivery item issues comment"
        @purchase_delivery.purchase_delivery_items.first.issues_quantity = 2000
        @purchase_delivery.purchase_delivery_items.first.report
        assert_match /n'est pas valide/, @purchase_delivery.purchase_delivery_items.first.errors.on(:issues_quantity)
      end
      
      context "and which is reported whithout reshipment" do
        setup do
          @purchase_delivery.purchase_delivery_items.first.issues_comment = "purchase_delivery item issues comment"
          @purchase_delivery.purchase_delivery_items.first.issues_quantity = 100
          flunk "purchase_delivery_item should be reported" unless @purchase_delivery.purchase_delivery_items.first.report
        end
          
        subject {@purchase_delivery.purchase_delivery_items.first}
        should_validate_presence_of :issues_comment
        should_validate_numericality_of :issues_quantity
      
        should "be reported" do
          assert @purchase_delivery.purchase_delivery_items.first.was_reported?
        end
          
        should "have possibility to be reported" do
          assert @purchase_delivery.purchase_delivery_items.first.can_be_reported?
        end
          
        should "not have a issue purchase order" do
          assert_nil @purchase_delivery.purchase_delivery_items.first.issue_purchase_order_supply 
        end
      end
      
      context "and which is reported with reshipment" do
        setup do
          @purchase_delivery.purchase_delivery_items.first.issues_comment = "purchase_delivery item issues comment"
          @purchase_delivery.purchase_delivery_items.first.issues_quantity = 100
          @purchase_delivery.purchase_delivery_items.first.must_be_reshipped = true
          flunk "purchase_delivery_item should be reported" unless @purchase_delivery.purchase_delivery_items.first.report
        end
          
        subject {@purchase_delivery.purchase_delivery_items.first}
        should_validate_presence_of :issues_comment
        should_validate_numericality_of :issues_quantity
        
        should "be reported" do
          assert @purchase_delivery.purchase_delivery_items.first.was_reported?
        end
        
        should "have possibility to be reported" do
          assert @purchase_delivery.purchase_delivery_items.first.can_be_reported?
        end
        
        should "have a issue purchase order" do
          assert_not_nil @purchase_delivery.purchase_delivery_items.first.issue_purchase_order_supply 
        end
        
        should "destroy issue purchase order if must_be_reshipped is deselected" do
          @purchase_delivery.purchase_delivery_items.first.must_be_reshipped = false
          @purchase_delivery.purchase_delivery_items.first.report
          assert_nil @purchase_delivery.purchase_delivery_items.first.issue_purchase_order_supply
        end
      end
    end      
    
    context "which is cancelled" do
      
      setup do
        @purchase_delivery.purchase_delivery_items.first.cancelled_comment = "cancelled purchase_delivery item"
        flunk "purchase_delivery item should be cancelled" unless @purchase_delivery.purchase_delivery_items.first.cancel
      end
      
      subject {@purchase_delivery.purchase_delivery_items.first}
      
      should_validate_presence_of :cancelled_comment
      
      should "be cancelled" do
        assert @purchase_delivery.purchase_delivery_items.first.was_cancelled?
      end
      
      should "not be able to be cancelled" do
        assert !@purchase_delivery.purchase_delivery_items.first.can_be_cancelled?
      end
    end 
  end
end
