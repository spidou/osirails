class ParcelItem < ActiveRecord::Base

  belongs_to :parcel
  belongs_to :purchase_order_supply
  
  def can_be_cancelled?
    (untreated? and purchase_order.was_confirmed? and ((parcel and parcel.was_processing) or !parcel)) or (processing? and purchase_order.was_confirmed? and parcel.was_processing?)
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
  
  def get_parcel_item_total
    quantity.to_f * purchase_order_supply.get_unit_price_including_tax.to_f
  end
end
