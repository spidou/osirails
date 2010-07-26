require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseOrderTest < ActiveSupport::TestCase
  
  should_have_many :purchase_order_supplies
  should_have_many :parcel_items
  
  should_belong_to :invoice_document, :quotation_document, :canceller, :user, :supplier
  
  should_allow_values_for :status, nil
  should_validate_presence_of :user_id
  should_validate_presence_of :supplier_id
  
  context 'creating a new purchase order' do
    
    setup do
      @purchase_order = create_first_purchase_order
    end
    
    teardown do
      @purchase_order = nil
    end
    
    subject { @purchase_order }
    
    should "have many 'purchase_order_supplies'" do
      assert_equal 2, @purchase_order.purchase_order_supplies.count
    end
    
    should "have many 'supplier_supplies'" do
#      assert_equal 2, @purchase_order.supplier_supplies.count
    end
  end
  
end
