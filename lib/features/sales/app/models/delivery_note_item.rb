class DeliveryNoteItem < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :quote_item
  
  has_many :discards
  
  validates_numericality_of :quantity
  
  validates_presence_of :quote_item_id
  validates_presence_of :quote_item, :if => :quote_item_id
  
  validates_associated :discards
  
  validate :validates_quantity_range
  
  attr_accessor :order_id
  
  def quantity
    self[:quantity] ||= 0
  end
  
  def validates_quantity_range
    #return if quote_item.nil? or ( !new_record? and !quantity_changed? )
    return unless quote_item and ( new_record? or quantity_changed? )
    min = 0
    max = remaining_quantity_to_deliver || 0
    if quantity and !(min..max).include?(quantity)
      errors.add(:quantity, "doit être compris entre #{min} et #{max}")
    end
  end
  
  # return discard's quantity of the delivered_delivery_intervention of the associated delivery_note
  def discard_quantity
    return 0 unless delivery_note and delivery_note.delivered_delivery_intervention
    
    discard = discards.detect{ |d| d.delivery_intervention_id == delivery_note.delivered_delivery_intervention.id }
    discard ? discard.quantity : 0
  end
  
  def really_delivered_quantity
    quantity - discard_quantity
  end
  
  # return remaining quantity for next delivery
  def remaining_quantity_to_deliver
    ( quote_item.quantity || 0 ) - already_delivered_or_scheduled_quantity
  end

  def already_delivered_or_scheduled_quantity
    return 0 if delivery_note.nil? and order_id.nil?

    siblings = delivery_note ? delivery_note.siblings : Order.find(order_id).delivery_notes.actives
    siblings.collect(&:delivery_note_items).flatten.select{ |x| x.quote_item_id == self.quote_item_id }.collect(&:really_delivered_quantity).sum
  end
end
