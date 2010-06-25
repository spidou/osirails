class PurchaseOrderSupply < ActiveRecord::Base

  has_many :request_order_supplies
  has_many :purchase_request_supplies, :through => :request_order_supplies
   
  belongs_to :purchase_order
  belongs_to :parcel
  belongs_to :supply
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  
  STATUS_UNTREATED = nil
  STATUS_PROCESSING = "processing"
  STATUS_SENT_BACK = "sent_back"
  STATUS_RESHIPPED = "reshipped"
  STATUS_REIMBURSED = "reimbursed"
  STATUS_CANCELLED = "cancelled"
  
  validates_presence_of :supply_id, :supplier_designation, :supplier_reference, :taxes
  validates_presence_of :cancelled_by, :if => :cancelled_at
    
  validates_numericality_of :quantity, :fob_unit_price , :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0

  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_SENT_BACK, STATUS_RESHIPPED, STATUS_REIMBURSED, STATUS_CANCELLED ]
  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_CANCELLED ], :if => :was_untreated?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_CANCELLED, STATUS_SENT_BACK ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_SENT_BACK, STATUS_RESHIPPED, STATUS_REIMBURSED ], :if => :was_sent_back?
  validates_inclusion_of :status, :in => [ STATUS_RESHIPPED ], :if => :was_reshipped?
  validates_inclusion_of :status, :in => [ STATUS_REIMBURSED ], :if => :was_reimbursed?
  
  def untreated?
    status == STATUS_UNTREATED
  end
  
  def processing?
    status == STATUS_PROCESSING
  end
  
  def sent_back?
    status == STATUS_SENT_BACK
  end
  
  def reshipped?
    status == STATUS_RESHIPPED
  end
  
  def reimbursed?
    status == STATUS_REIMBURSED
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def completed?
    reshipped? or reimbursed? or ( processing? and parcel.received?)
  end
  
  def was_untreated?
    status_was == STATUS_UNTREATED
  end
  
  def was_processing?
    status_was == STATUS_PROCESSING
  end
  
  def was_sent_back?
    status_was == STATUS_SENT_BACK
  end
  
  def was_reshipped?
    status_was == STATUS_RESHIPPED
  end
  
  def was_reimbursed?
    status_was == STATUS_REIMBURSED
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def can_be_processed?
    was_untreated?
  end
  
  def can_be_sent_back?
    was_processing?
  end
  
  def can_be_reshipped?
    was_sent_back?
  end
  
  def can_be_reimbursed?
    was_sent_back?
  end
  
  def can_be_cancelled?
    (was_untreated? and !purchase_order.was_draft?) or was_processing?
  end
  
  def can_be_deleted?
    new_record? or purchase_order.was_draft?
  end
  
  def treat
    if can_be_processing?
      self.status = STATUS_PROCESSING
      self.save
    else
      false
    end
  end
  
  def send_back
    if can_be_sent_back?
      self.status = STATUS_SENT_BACK
      self.sent_back_at = Time.now
      self.save
    else
      false
    end
  end
  
  def reship
    if can_be_reshipped?
      self.status = STATUS_RESHIPPED
      self.reshipped_at = Time.now
      self.save
    else
      false
    end
  end
  
  def reimburse
    if can_be_reimbursed?
      self.status = STATUS_REIMBURSED
      self.reimbursed_at = Time.now
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
  
  
  def not_cancelled_purchase_request_supplies
    purchase_request_supplies = PurchaseRequestSupply.all(:include => :purchase_request,  :conditions =>['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL',supply_id])
  end
  
  def unconfirmed_purchase_request_supplies
    res = []
    for purchase_request_supply in not_cancelled_purchase_request_supplies
      res << purchase_request_supply unless purchase_request_supply.confirmed_purchase_order_supply
    end
    res
  end
  
end
