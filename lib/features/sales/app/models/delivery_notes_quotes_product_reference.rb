class DeliveryNotesQuotesProductReference < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :quotes_product_reference
  
  has_one :discard
  
  validates_numericality_of :quantity
  
  validates_presence_of :quotes_product_reference_id
  validates_presence_of :quotes_product_reference, :if => :quotes_product_reference_id
  
  validates_associated :discard
  
  validate :validates_quantity_range
  
  def validates_quantity_range
    return unless quotes_product_reference
    min = 0
    max = quotes_product_reference.quantity || 0
    if quantity and !(min..max).include?(quantity)
      errors.add(:quantity, "doit être compris entre #{min} et #{max}")
    end
  end
end
