class Discard < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :delivery_notes_quotes_product_reference
  belongs_to :discard_type
  
  validates_presence_of :discard_type_id, :delivery_notes_quotes_product_reference_id
  validates_presence_of :discard_type,                            :if => :discard_type_id
  validates_presence_of :delivery_notes_quotes_product_reference, :if => :delivery_notes_quotes_product_reference_id
  validates_presence_of :comments
  
  validates_numericality_of :quantity, :if => :delivery_notes_quotes_product_reference
  validate :validates_quantity_range
  
  def validates_quantity_range
    if delivery_notes_quotes_product_reference
      min = 1
      max = delivery_notes_quotes_product_reference.quantity
      if quantity and !(min..max).include?(quantity)
        errors.add(:quantity, "doit être compris entre #{min} et #{max}")
      end
    end
  end
  
end
