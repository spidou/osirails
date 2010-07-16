class ParcelItem < ActiveRecord::Base

  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]

  belongs_to :parcel
  belongs_to :purchase_order_supply
  
  validates_presence_of :purchase_order_supply_id
  validates_numericality_of :quantity, :greater_than => 0
  
  validate :validates_quantity_for_parcel_item, :if => :new_record?

  attr_accessor :selected 
  attr_accessor :tmp_selected
  
  after_save :automatically_cancel_parcel_if_empty, :if => :cancelled_at_was
  
  def validates_quantity_for_parcel_item
    errors.add(:quantity, "quantity not valid")  if self.selected.to_i == 1 && self.quantity > self.purchase_order_supply.remaining_quantity_for_parcel
  end
  
  def can_be_cancelled?
    !was_cancelled? and !new_record? and !parcel.was_received?
    #(untreated? and purchase_order.was_confirmed? and ((parcel and parcel.was_processing_by_supplier) or !parcel)) or (processing_by_supplier? and purchase_order.was_confirmed? and parcel.was_processing_by_supplier?)
  end
  
  def can_be_reported?
    #TODO
    return true if parcel.received? and !purchase_order_supply.purchase_order.was_received?
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def cancel(attributes)
    if can_be_cancelled?
      self.attributes = attributes
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
  
  def untreated?
    purchase_order_supply.untreated?
  end
  
  def get_parcel_item_total
    quantity.to_f * purchase_order_supply.get_unit_price_including_tax.to_f
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
  
  def is_the_last_not_cancelled?
    not_cancelled_parcel_items
    for parcel_item in parcel.parcel_items
      if !parcel_item.was_cancelled?
        not_cancelled_parcel_items.push parcel_item
      end
    end
    if not_cancelled_parcel_items.count == 1
      true
    else
      false
    end
  end
  
  def automatically_cancel_parcel_if_empty
    if is_the_last_not_cancelled?
      parcel.cancel
    end
  end
end
