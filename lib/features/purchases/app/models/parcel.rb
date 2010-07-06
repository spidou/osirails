class Parcel < ActiveRecord::Base

  has_many :parcel_items
  has_many :purchase_order_supplies, :through => "parcel_items"

  STATUS_PROCESSING = nil
  STATUS_SHIPPED = "shipped"
  STATUS_RECEIVED_BY_FORWARDER = "received_by_forwarder"
  STATUS_RECEIVED = "received"
  STATUS_CANCELLED = "cancel"

  validates_presence_of :conveyance, :state
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED, STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED ]
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_SHIPPED, STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED ], :if => :was_shipped?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED], :if => :was_received_by_forwarder?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED ], :if => :was_received?

  def processing?
    status = STATUS_PROCESSING
  end

  def shipped?
    status = STATUS_SHIPPED
  end

  def received_by_forwarder?
    status = STATUS_RECEIVED_BY_FORWARDER
  end

  def received?
    status = STATUS_RECEIVED
  end

  def cancelled?
    status = STATUS_CANCELLED
  end

  def was_processing?
    status_was = STATUS_PROCESSING
  end

  def was_shipped?
    status_was = STATUS_SHIPPED
  end

  def was_received_by_forwarder?
    status_was = STATUS_RECEIVED_BY_FORWARDER
  end

  def was_received?
    status_was = STATUS_RECEIVED
  end

  def was_cancelled?
    status_was = STATUS_CANCELLED
  end

  def can_be_shipped?
    processing?
  end

  def can_be_received_by_forwarder?
    shipped?
  end

  def direct?

  end

  def can_be_received?
    received_by_forwarder? or direct?
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

  def receive_by_supplier
    if can_be_received_by_forwarder?
      self.status = STATUS_RECEIVED_BY_FORWARDER
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

