require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseDeliveryTest < ActiveSupport::TestCase
  
  should_have_many :purchase_delivery_items
  should_have_many :purchase_order_supplies, :through => :purchase_delivery_items
  
  should_belong_to :delivery_document
  
  #TODO should_validate_date :processing_by_supplier_since
  #TODO should_validate_date :shipped_on
  #TODO should_validate_date :received_by_forwarder_on
  #TODO should_validate_date :received_on
   
  #should_validate_presence_of :cancelled_comment
  #should_validate_presence_of :reference
  
  context "A new purchase_delivery" do
    
    setup do
      @purchase_order = create_purchase_order
      @purchase_delivery = PurchaseDelivery.new
    end
    
    subject {@purchase_delivery}
    
    should_allow_values_for :status, PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER, PurchaseDelivery::STATUS_SHIPPED, PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER, PurchaseDelivery::STATUS_RECEIVED
    should_not_allow_values_for :status, PurchaseDelivery::STATUS_CANCELLED
    
    context "whose purchase_delivery items are building with build_purchase_delivery_items_with_purchase_order_supplies" do
      setup do
        flunk "purchase_delivery should not have purchase_delivery_items" if @purchase_delivery.purchase_delivery_items.size > 0
        @purchase_delivery.purchase_delivery_items = @purchase_delivery.build_purchase_delivery_items_with_purchase_order_supplies(@purchase_order.purchase_order_supplies)
        flunk "purchase_delivery should have purchase_delivery_items" unless (@purchase_delivery_items = @purchase_delivery.purchase_delivery_items)
      end
      
      should "have a collection of purchase_delivery items" do
        assert_equal 2, @purchase_delivery_items.size
      end    
        
    end
    
   context "whose purchase_delivery items are building with purchase_delivery_item_attributes" do
      setup do
        flunk "purchase_delivery should not have purchase_delivery_items" if @purchase_delivery.purchase_delivery_items.size > 0
       @purchase_delivery.purchase_delivery_item_attributes = [{:purchase_order_supply_id => @purchase_order.purchase_order_supplies.first.id, 
                                          :quantity => @purchase_order.purchase_order_supplies.first.quantity, 
                                          :selected => "1"}]
        @purchase_delivery_item = @purchase_delivery.purchase_delivery_items.first 
      end
      
      should "have a new purchase_delivery item" do
        assert @purchase_delivery_item.new_record?
      end    
        
    end
    
    context "without purchase_delivery items associated" do
     
      should "have invalid purchase_delivery_items " do
        @purchase_delivery.valid?
        assert_match /Veuillez selectionner au moins une fourniture dans votre colis/, @purchase_delivery.errors.on(:purchase_delivery_items)
      end  
    end 
    
    context "with purchase_delivery items associated" do
      setup do
        @purchase_delivery = PurchaseDelivery.new
        @purchase_delivery = build_purchase_delivery_item_for(@purchase_delivery, nil)
      end
       
      should "have valid purchase_delivery_items" do
        @purchase_delivery.valid?
        assert !@purchase_delivery.errors.invalid?(:purchase_delivery_items)
      end  
      
      should "be able to be saved" do
        @purchase_delivery.save!
        assert !@purchase_delivery.new_record?
      end
      
      context "when purchase_delivery is saving" do
        setup do
          @purchase_delivery.build_purchase_delivery_items_with_purchase_order_supplies(@purchase_order.purchase_order_supplies)
          flunk "purchase_delivery should have purchase_delivery_items" unless @purchase_delivery.purchase_delivery_items.any?
          @purchase_delivery.purchase_delivery_items.first.selected = "1"
        end
        
        should "be able to unsave purchase_delivery_item unselected" do
          assert_equal 3, @purchase_delivery.purchase_delivery_items.size
          @purchase_delivery.save!
          assert_equal 1, @purchase_delivery.purchase_delivery_items.count
        end
      end
    end 
  end
  
   context "A purchase_delivery" do
    
    setup do
      @purchase_delivery = processing_by_supplier_purchase_delivery
    end
    
    subject {@purchase_delivery}
    should_validate_presence_of :reference
    
    should "return purchase order associated" do
      assert_not_nil @purchase_delivery.purchase_order
    end
    
    should "put automatically purchase order status to processing by supplier" do
      assert @purchase_delivery.purchase_order.processing_by_supplier?
    end
    
    context "which is in PROCESSING_BY_SUPPLIER status" do
      
      subject {@purchase_delivery}
  
      should_allow_values_for :status, PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER, PurchaseDelivery::STATUS_SHIPPED, PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER, PurchaseDelivery::STATUS_RECEIVED, PurchaseDelivery::STATUS_CANCELLED
      #TODO should_validate_date :processing_by_supplier_since
      
      should "be processing by supplier" do
        assert @purchase_delivery.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@purchase_delivery.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@purchase_delivery.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@purchase_delivery.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@purchase_delivery.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@purchase_delivery.can_be_processed_by_supplier? 
      end
      
      should "be able to have STATUS_SHIPPED status" do
        assert @purchase_delivery.can_be_shipped? 
      end
      
      should "be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert @purchase_delivery.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @purchase_delivery.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @purchase_delivery.can_be_cancelled? 
      end
      
    end
    
    context "which is in SHIPPED status" do
      
      setup do
        @purchase_delivery = shipped_purchase_delivery
      end
      
      subject {@purchase_delivery}
  
      should_allow_values_for :status, PurchaseDelivery::STATUS_SHIPPED, PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER, PurchaseDelivery::STATUS_RECEIVED, PurchaseDelivery::STATUS_CANCELLED
      should_not_allow_values_for :status, PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER
      
      #TODO should_validate_date :shipped_on
      #TODO should_validate_persistance_of :ship_conveyance 
      
      should "NOT be processing by supplier" do
        assert !@purchase_delivery.was_processing_by_supplier?
      end
      
      should "be shipped" do
        assert @purchase_delivery.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@purchase_delivery.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@purchase_delivery.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@purchase_delivery.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@purchase_delivery.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@purchase_delivery.can_be_shipped? 
      end
      
      should "be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert @purchase_delivery.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @purchase_delivery.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @purchase_delivery.can_be_cancelled? 
      end
      
    end
    
    context "which is in RECEIVED_BY_FORWARDER status" do
      
      setup do
        @purchase_delivery = received_by_forwarder_purchase_delivery
      end
      
      subject {@purchase_delivery}
  
      should_allow_values_for :status, PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER, PurchaseDelivery::STATUS_RECEIVED, PurchaseDelivery::STATUS_CANCELLED
      should_not_allow_values_for :status, PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER, PurchaseDelivery::STATUS_SHIPPED
      
      #TODO should_validate_date :received_by_forwarder_on
      
      should "NOT be processing by supplier" do
        assert !@purchase_delivery.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@purchase_delivery.was_shipped?
      end
      
      should "be received_by_forwarder" do
        assert @purchase_delivery.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@purchase_delivery.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@purchase_delivery.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@purchase_delivery.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@purchase_delivery.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@purchase_delivery.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @purchase_delivery.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @purchase_delivery.can_be_cancelled? 
      end
    end
    
    context "which is in RECEIVED status" do
      
      setup do
        @purchase_delivery = received_purchase_delivery
      end
      
      subject {@purchase_delivery}
  
      should_allow_values_for :status, PurchaseDelivery::STATUS_RECEIVED
      should_not_allow_values_for :status, PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER, PurchaseDelivery::STATUS_SHIPPED, PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER, PurchaseDelivery::STATUS_CANCELLED
      
      #TODO should_validate_date :received_on
      
      should "NOT be processing by supplier" do
        assert !@purchase_delivery.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@purchase_delivery.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@purchase_delivery.was_received_by_forwarder?
      end
      
      should "be received" do
        assert @purchase_delivery.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@purchase_delivery.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@purchase_delivery.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@purchase_delivery.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@purchase_delivery.can_be_received_by_forwarder? 
      end
      
      should "NOT be able to have STATUS_RECEIVED status" do
        assert !@purchase_delivery.can_be_received? 
      end
      
      should "NOT be able to have STATUS_CANCELLED status" do
        assert !@purchase_delivery.can_be_cancelled? 
      end
      
    end
    
    context "which is in CANCELLED status" do
      
      setup do
        @purchase_delivery = cancelled_purchase_delivery
      end
      
      subject {@purchase_delivery} 
      #TODO should_validate_persistance_of :cancelled_comment
      
      should "NOT be processing by supplier" do
        assert !@purchase_delivery.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@purchase_delivery.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@purchase_delivery.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@purchase_delivery.was_received?
      end
      
      should "be cancelled" do
        assert @purchase_delivery.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@purchase_delivery.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@purchase_delivery.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@purchase_delivery.can_be_received_by_forwarder? 
      end
      
      should "NOT be able to have STATUS_RECEIVED status" do
        assert !@purchase_delivery.can_be_received? 
      end
      
      should "NOT be able to have STATUS_CANCELLED status" do
        assert !@purchase_delivery.can_be_cancelled? 
      end
    end
    
  end
end
