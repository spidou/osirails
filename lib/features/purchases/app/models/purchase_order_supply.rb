class PurchaseOrderSupply < ActiveRecord::Base

  belongs_to :purchase_order
  belongs_to :parcel
  belongs_to :supply
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  has_one :purchase_request_supply
  
  STATUS_UNTREATED = nil
  STATUS_PROCESSING = "processing"
  STATUS_RETURNED = "returned"
  STATUS_FORWARDED = "forwarded"
  STATUS_REIMBURSED = "reimboursed"
  STATUS_CANCELLED = "cancelled"
  
  validates_presence_of :supply_id, :quantity, :previsional_delivary_date
  validates_presence_of :cancelled_by, :if => :was_cancelled?
  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_RETURNED, STATUS_FORWARDED, STATUS_REIMBURSED, STATUS_CANCELLED ]
  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_CANCELLED ], :if => :was_untreated?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_CANCELLED, STATUS_RETURNED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_RETURNED, STATUS_FORWARDED, STATUS_REIMBURSED ], :if => :was_returned?
  validates_inclusion_of :status, :in => [ STATUS_FORWARDED ], :if => :was_forwarded?
  validates_inclusion_of :status, :in => [ STATUS_REIMBURSED ], :if => :was_reimboursed?
  
  def untreated?
    status == STATUS_UNTREATED
  end
  
  def processing?
    status == STATUS_PROCESSING
  end
  
  def returned?
    status == STATUS_RETURNED
  end
  
  def forwarded?
    status == STATUS_FORWARDED
  end
  
  def reimboursed?
    status == STATUS_REIMBURSED
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def was_untreated?
    status_was == STATUS_UNTREATED
  end
  
  def was_processing?
    status_was == STATUS_PROCESSING
  end
  
  def was_returned?
    status_was == STATUS_RETURNED
  end
  
  def was_forwarded?
    status_was == STATUS_FORWARDED
  end
  
  def was_reimboursed?
    status_was == STATUS_REIMBURSED
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def can_be_processed?
    was_untreated?
  end
  
  def can_be_returned?
    was_processing?
  end
  
  def can_be_forwarded?
    was_returned?
  end
  
  def can_be_reimboursed?
    was_returned?
  end
  
  def can_be_cancelled?
    was_untreated? or was_processing?
  end
  
  def treat
    if can_be_processing?
      self.status = STATUS_PROCESSING
      self.save
    else
      false
    end
  end
  
  def return
    if can_be_returned?
      self.status = STATUS_RETURNED
      self.returned_at = Time.now
      self.save
    else
      false
    end
  end
  
  def redirect
    if can_be_forwarded?
      self.status = STATUS_FORWARDED
      self.forwarded_at = Time.now
      self.save
    else
      false
    end
  end
  
  def reimbourse
    if can_be_reimboursed?
      self.status = STATUS_REIMBURSED
      self.reimboursed_at = Time.now
      self.save
    else
      false
    end
  end
  
  def cancel(attributes)
    if can_be_cancelled?
      self.attributes = attributes
      self.status = STATUS_CANCELLED
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
end
