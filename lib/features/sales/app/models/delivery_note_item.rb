class DeliveryNoteItem < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :quote_item
  
  has_one :discard
  
  validates_numericality_of :quantity
  
  validates_presence_of :quote_item_id
  validates_presence_of :quote_item, :if => :quote_item_id
  
  validates_associated :discard
  
  validate :validates_quantity_range
  
  def validates_quantity_range
    return unless quote_item
    min = 0
    max = quote_item.quantity || 0
    if quantity and !(min..max).include?(quantity)
      errors.add(:quantity, "doit être compris entre #{min} et #{max}")
    end
  end
end
