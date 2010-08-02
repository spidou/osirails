require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class ParcelTest < ActiveSupport::TestCase
  
  should_have_many :parcel_items
  should_have_many :purchase_order_supplies, :through => :parcel_items
  
  should_belong_to :delivery_document
  
  #TODO should_validate_date :processing_by_supplier_since
  #TODO should_validate_date :shipped_on
  #TODO should_validate_date :received_by_forwarder_on
  #TODO should_validate_date :received_on
   
  #should_validate_presence_of :cancelled_comment
  #should_validate_presence_of :reference
  
  context "A new parcel" do
    
    setup do
      @purchase_order = create_purchase_order(1, 2)
      @parcel = build_parcel
    end
    
    subject {@parcel}
    
    should_allow_values_for :status, Parcel::STATUS_PROCESSING_BY_SUPPLIER, Parcel::STATUS_SHIPPED, Parcel::STATUS_RECEIVED_BY_FORWARDER, Parcel::STATUS_RECEIVED
    should_not_allow_values_for :status, Parcel::STATUS_CANCELLED
    
    context "whose parcel items are building with build_parcel_items_with_purchase_order_supplies" do
      setup do
        flunk "parcel should not have parcel_items" if @parcel.parcel_items.size > 0
        @parcel.parcel_items = @parcel.build_parcel_items_with_purchase_order_supplies(@purchase_order.purchase_order_supplies)
        flunk "parcel should have parcel_items" unless (@parcel_items = @parcel.parcel_items)
      end
      
      should "have a collection of parcel items" do
        assert_equal 2, @parcel_items.size
      end    
        
    end
    
   context "whose parcel items are building with parcel_item_attributes" do
      setup do
        flunk "parcel should not have parcel_items" if @parcel.parcel_items.size > 0
       @parcel.parcel_item_attributes = [{:purchase_order_supply_id => @purchase_order.purchase_order_supplies.first.id, 
                                          :quantity => @purchase_order.purchase_order_supplies.first.quantity, 
                                          :selected => "1"}]
                                          
                                        
        @parcel_item = @parcel.parcel_items.first 
      end
      
      should "have a new parcel item" do
        assert @parcel_item.new_record?
      end    
        
    end
    
    context "without parcel items associated" do
     
      should "have invalid parcel_items " do
        @parcel.valid?
        assert_match /Veuillez selectionner au moins une fourniture dans votre colis/, @parcel.errors.on(:parcel_items)
      end  
    end 
    
    context "with parcel items associated" do
      setup do
        @parcel = build_parcel
        @parcel = build_parcel_item_for(@parcel)
      end
       
      should "have valid parcel_items" do
        @parcel.valid?
        assert !@parcel.errors.invalid?(:parcel_items)
      end  
      
      should "be able to be saved" do
        @parcel.save!
        assert !@parcel.new_record?
      end
      
      context "when parcel is saving" do
        setup do
          @parcel.build_parcel_items_with_purchase_order_supplies(@purchase_order.purchase_order_supplies)
          flunk "parcel should have parcel_items" unless @parcel.parcel_items.any?
          @parcel.parcel_items.first.selected = "1"
        end
        
        should "be able to unsave parcel_item unselected" do
          assert_equal 3, @parcel.parcel_items.size
          @parcel.save!
          assert_equal 1, @parcel.parcel_items.count
        end
      end
      
    end 
  end
  
  context "A parcel" do
    
    setup do
      @parcel = processing_by_supplier_parcel
    end
    
    subject {@parcel}
    should_validate_presence_of :reference
    
    should "return purchase order associated" do
      assert_not_nil @parcel.get_purchase_order
    end
    
    should "put automatically purchase order status to processing by supplier" do
      assert @parcel.get_purchase_order.processing_by_supplier?
    end
    
    context "which is in PROCESSING_BY_SUPPLIER status" do
      
      subject {@parcel}
  
      should_allow_values_for :status, Parcel::STATUS_PROCESSING_BY_SUPPLIER, Parcel::STATUS_SHIPPED, Parcel::STATUS_RECEIVED_BY_FORWARDER, Parcel::STATUS_RECEIVED, Parcel::STATUS_CANCELLED
      #TODO should_validate_date :processing_by_supplier_since
      
      should "be processing by supplier" do
        assert @parcel.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@parcel.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@parcel.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@parcel.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@parcel.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@parcel.can_be_processed_by_supplier? 
      end
      
      should "be able to have STATUS_SHIPPED status" do
        assert @parcel.can_be_shipped? 
      end
      
      should "be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert @parcel.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @parcel.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @parcel.can_be_cancelled? 
      end
      
    end
    
    context "which is in SHIPPED status" do
      
      setup do
        @parcel = shipped_parcel
      end
      
      subject {@parcel}
  
      should_allow_values_for :status, Parcel::STATUS_SHIPPED, Parcel::STATUS_RECEIVED_BY_FORWARDER, Parcel::STATUS_RECEIVED, Parcel::STATUS_CANCELLED
      should_not_allow_values_for :status, Parcel::STATUS_PROCESSING_BY_SUPPLIER
      
      #TODO should_validate_date :shipped_on
      #TODO should_validate_persistance_of :conveyance 
      
      should "NOT be processing by supplier" do
        assert !@parcel.was_processing_by_supplier?
      end
      
      should "be shipped" do
        assert @parcel.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@parcel.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@parcel.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@parcel.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@parcel.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@parcel.can_be_shipped? 
      end
      
      should "be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert @parcel.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @parcel.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @parcel.can_be_cancelled? 
      end
      
    end
    
    context "which is in RECEIVED_BY_FORWARDER status" do
      
      setup do
        @parcel = received_by_forwarder_parcel
      end
      
      subject {@parcel}
  
      should_allow_values_for :status, Parcel::STATUS_RECEIVED_BY_FORWARDER, Parcel::STATUS_RECEIVED, Parcel::STATUS_CANCELLED
      should_not_allow_values_for :status, Parcel::STATUS_PROCESSING_BY_SUPPLIER, Parcel::STATUS_SHIPPED
      
      #TODO should_validate_date :received_by_forwarder_on
      
      should "NOT be processing by supplier" do
        assert !@parcel.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@parcel.was_shipped?
      end
      
      should "be received_by_forwarder" do
        assert @parcel.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@parcel.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@parcel.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@parcel.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@parcel.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@parcel.can_be_received_by_forwarder? 
      end
      
      should "be able to have STATUS_RECEIVED status" do
        assert @parcel.can_be_received? 
      end
      
      should "be able to have STATUS_CANCELLED status" do
        assert @parcel.can_be_cancelled? 
      end
    end
    
    context "which is in RECEIVED status" do
      
      setup do
        @parcel = received_parcel
      end
      
      subject {@parcel}
  
      should_allow_values_for :status, Parcel::STATUS_RECEIVED
      should_not_allow_values_for :status, Parcel::STATUS_PROCESSING_BY_SUPPLIER, Parcel::STATUS_SHIPPED, Parcel::STATUS_RECEIVED_BY_FORWARDER, Parcel::STATUS_CANCELLED
      
      #TODO should_validate_date :received_on
      
      should "NOT be processing by supplier" do
        assert !@parcel.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@parcel.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@parcel.was_received_by_forwarder?
      end
      
      should "be received" do
        assert @parcel.was_received?
      end
      
      should "NOT be cancelled" do
        assert !@parcel.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@parcel.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@parcel.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@parcel.can_be_received_by_forwarder? 
      end
      
      should "NOT be able to have STATUS_RECEIVED status" do
        assert !@parcel.can_be_received? 
      end
      
      should "NOT be able to have STATUS_CANCELLED status" do
        assert !@parcel.can_be_cancelled? 
      end
      
    end
    
    context "which is in CANCELLED status" do
      
      setup do
        @parcel = cancelled_parcel
      end
      
      subject {@parcel} 
      #TODO should_validate_persistance_of :cancelled_comment
      
      should "NOT be processing by supplier" do
        assert !@parcel.was_processing_by_supplier?
      end
      
      should "NOT be shipped" do
        assert !@parcel.was_shipped?
      end
      
      should "NOT be received_by_forwarder" do
        assert !@parcel.was_received_by_forwarder?
      end
      
      should "NOT be received" do
        assert !@parcel.was_received?
      end
      
      should "be cancelled" do
        assert @parcel.was_cancelled?
      end
      
      should "NOT be able to have STATUS_PROCESSING_BY_SUPPLIER status" do
        assert !@parcel.can_be_processed_by_supplier? 
      end
      
      should "NOT be able to have STATUS_SHIPPED status" do
        assert !@parcel.can_be_shipped? 
      end
      
      should "NOT be able to have STATUS_RECEIVED_BY_FORWARDER status" do
        assert !@parcel.can_be_received_by_forwarder? 
      end
      
      should "NOT be able to have STATUS_RECEIVED status" do
        assert !@parcel.can_be_received? 
      end
      
      should "NOT be able to have STATUS_CANCELLED status" do
        assert !@parcel.can_be_cancelled? 
      end
    end
    
  end
  
end
