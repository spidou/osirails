class Parcel < ActiveRecord::Base
  
  has_many :purchase_order_supplies
  
  STATUS_PROCESSING = nil
  STATUS_SHIPPED = "shipped"
  STATUS_ARRIVED = "arrived"
  STATUS_RECEIVED = "received"
  
  validates_presence_of :conveyance, :state
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED, STATUS_ARRIVED, STATUS_RECEIVED ]
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_SHIPPED, STATUS_ARRIVED, STATUS_RECEIVED ], :if => :was_shipped?
  validates_inclusion_of :status, :in => [ STATUS_ARRIVED, STATUS_RECEIVED], :if => :was_ARRIVED?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED ], :if => :was_received?
  
  def processing?
    status = STATUS_PROCESSING
  end
  
  def shipped?
    status = STATUS_SHIPPED
  end
  
  def arrived?
    status = STATUS_ARRIVED
  end
  
  def received?
    status = STATUS_RECEIVED
  end
  
  def was_processing?
    status_was = STATUS_PROCESSING
  end
  
  def was_shipped?
    status_was = STATUS_SHIPPED
  end
  
  def was_arrived?
    status_was = STATUS_ARRIVED
  end
  
  def was_received?
    status_was = STATUS_RECEIVED
  end
  
  def can_be_shipped?
    processing?
  end
  
  def can_be_arrived?
    shipped?
  end
  
  #TODO
  #def can_be_received?
   # for purchase_order_supply in purchase_order_supplies
     # direct? = purchase_order_supply.purchase_order.direct == "direct"
    #end
    #arrived? or direct?
  #end
  
  def ship
    if can_be_shipped?
      self.status = STATUS_SHIPPED
      self.shipped_at = Date.today
      self.save
    else
      false
    end
  end

  def arrive
    if can_be_arrived?
      self.status = STATUS_ARRIVED
      self.recovered_at = Date.today
      self.save
    else
      false
    end
  end

  def receive
    if can_be_received?
      self.status = STATUS_RECEIVED
      self.received_at = Date.today
      self.save
    else
      false
    end
  end
end
