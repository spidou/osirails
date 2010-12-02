require File.dirname(__FILE__) + '/../sales_test'
 
class DeliveryNoteItemTest < ActiveSupport::TestCase
  should_belong_to :delivery_note, :end_product
  
  should_have_many :discards
  
  should_validate_numericality_of :quantity
  
  should_validate_presence_of :end_product, :with_foreign_key => :default
  
  #TODO test validates_quantity_range
  #          should_destroy?
  #          reference
  #          designation
  #          description
  #          order_quantity
  #          quantity
  #          discard_quantity
  #          ready_to_deliver_quantity
  #          really_delivered_quantity
  #          remaining_quantity_to_deliver
  #          already_delivered_or_scheduled_quantity
end
