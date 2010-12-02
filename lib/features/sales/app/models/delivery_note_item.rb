class DeliveryNoteItem < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :end_product
  
  has_many :discards
  
  validates_presence_of :end_product_id
  validates_presence_of :end_product, :if => :end_product_id
  
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0
  
  validates_associated :discards
  
  validate :validates_quantity_range
  
  attr_accessor :order_id
  
  def validates_quantity_range
    return unless end_product and ( new_record? or quantity_changed? )
    min = 0
    max = remaining_quantity_to_deliver || 0
    if quantity and !(min..max).include?(quantity)
      errors.add(:quantity, "doit être compris entre #{min} et #{max}")
    end
  end
  
  def should_destroy?
    quantity.zero?
  end
  
  def reference
    end_product && end_product.product_reference && end_product.product_reference.reference
  end
  
  def designation
    end_product && end_product.designation
  end
  
  def description
    end_product && end_product.description
  end
  
  def order_quantity
    end_product && end_product.quantity
  end
  
  def quantity
    self[:quantity] ||= 0
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
  
  def ready_to_deliver_quantity
    return 0 if delivery_note.nil? and order_id.nil?
    
    ready_to_deliver_end_products_and_quantities = if delivery_note
      delivery_note.ready_to_deliver_end_products_and_quantities
    else
      Order.find(order_id).ready_to_deliver_end_products_and_quantities
    end
    
    if h = ready_to_deliver_end_products_and_quantities.detect{ |h| h[:end_product_id] == end_product.id }
      h[:quantity]
    else
      0
    end
  end
  
  def already_delivered_or_scheduled_quantity #TODO can't we use EndProduct#already_delivered_or_scheduled_quantity instead ?
    return 0 if delivery_note.nil? and order_id.nil?

    siblings = delivery_note ? delivery_note.siblings : Order.find(order_id).delivery_notes.actives
    siblings.collect(&:delivery_note_items).flatten.select{ |x| x.end_product_id == self.end_product_id }.collect(&:really_delivered_quantity).sum
  end
  
  # return remaining quantity for next delivery
  def remaining_quantity_to_deliver #TODO can't we use EndProduct#remaining_quantity_to_deliver instead ?
    ready_to_deliver_quantity - already_delivered_or_scheduled_quantity
  end
end
