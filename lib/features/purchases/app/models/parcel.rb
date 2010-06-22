class Parcel < ActiveRecord::Base
  
  #relationships
  has_many :purchase_order_supplies
  
  STATUS_PROCESSING = nil
  STATUS_SHIPPED = "shipped"
  STATUS_RECEIVED = "received"
  STATUS_RECOVERED = "recovered"
  
  validates_presence_of :conveyance, :state
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED, STATUS_RECEIVED ]
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_SHIPPED, STATUS_RECEIVED ], :if => :was_shipped?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED, STATUS_RECOVERED ], :if => :was_received?
  validates_inclusion_of :status, :in => [ STATUS_RECOVERED ], :if => :was_recovered?
  
  def processing?
    status = STATUS_PROCESSING
  end
  
  def shipped?
    status = STATUS_SHIPPED
  end
  
  def received?
    status = (STATUS_RECEIVED or STATUS_RECOVERED)
  end
  
  def recovered?
    status = STATUS_RECOVERED
  end
  
  def was_processing?
    status_was = STATUS_PROCESSING
  end
  
  def was_shipped?
    status_was = STATUS_SHIPPED
  end
  
  def was_received?
    status_was = STATUS_RECEIVED
  end
  
  def was_recovered?
    status_was = STATUS_RECOVERED
  end
  
  def can_be_shipped?
    processing?
  end
  
  def can_be_received?
    shipped?
  end
  
  def can_be_recovered?
    received?
  end
  
  def ship
    if can_be_shipped?
      self.status = STATUS_SHIPPED
      self.shipped_at = Date.today
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
  
  def recover
    if can_be_recovered?
      self.status = STATUS_RECOVERED
      self.recovered_at = Date.today
      self.save
    else
      false
    end
  end
end
