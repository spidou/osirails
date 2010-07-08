class ParcelItem < ActiveRecord::Base

  belongs_to :parcel
  belongs_to :purchase_order_supply
  
  validates_presence_of :purchase_order_supply_id
  validates_numericality_of :quantity, :greater_than => 0
  
  validate :validates_quantity_for_parcel_item, :if => :new_record?

  attr_accessor :selected 
  
  def validates_quantity_for_parcel_item
    errors.add(:quantity, "quantity not valid")  if self.selected.to_i == 1 && self.quantity > self.purchase_order_supply.remaining_quantity_for_parcel
  end
  
  def can_be_cancelled?
    (untreated? and purchase_order.was_confirmed? and ((parcel and parcel.was_processing) or !parcel)) or (processing? and purchase_order.was_confirmed? and parcel.was_processing?)
  end

  def can_be_deleted?
    new_record? or purchase_order.was_draft?
  end

  def treat
    if can_be_processing?
      self.save
    else
      false
    end
  end

  def send_back
    if can_be_sent_back?
      self.save
    else
      false
    end
  end

  def reship
    if can_be_reshipped?
      self.save
    else
      false
    end
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
end

