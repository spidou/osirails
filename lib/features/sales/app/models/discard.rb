class Discard < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :delivery_note_item
  belongs_to :delivery_intervention
  
  validates_uniqueness_of :delivery_note_item_id, :scope => :delivery_intervention_id
  
  validates_presence_of :delivery_note_item_id
  validates_presence_of :delivery_note_item,  :if => :delivery_note_item_id
  
  validates_presence_of :comments
  
  validates_numericality_of :quantity, :if => :delivery_note_item
  
  validate :validates_quantity_range
  
  def validates_quantity_range
    if delivery_note_item
      min = 1
      max = delivery_note_item.quantity
      if quantity and !(min..max).include?(quantity)
        errors.add(:quantity, "doit être compris entre #{min} et #{max}")
      end
    end
  end
  
end
