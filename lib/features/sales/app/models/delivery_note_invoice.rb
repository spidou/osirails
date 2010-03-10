class DeliveryNoteInvoice < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :invoice
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy == true
  end
end
