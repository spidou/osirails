class PurchaseOrder < ActiveRecord::Base
  
  has_many :purchase_order_supplies
  belongs_to :invoice_document, :class_name => "PurchaseDocument"
  belongs_to :delivery_document, :class_name => "PurchaseDocument"
  belongs_to :quotation_document, :class_name => "PurchaseDocument"
  belongs_to :payment_document, :class_name => "PurchaseDocument"
  belongs_to :user
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  belongs_to :supplier
  belongs_to :payment_method
  
  STATUS_DRAFT = nil
  STATUS_CONFIRMED = "confirmed"
  STATUS_PROCESSING = "processing"
  STATUS_COMPLETED = "completed"
  STATUS_CANCELLED = "cancelled"
  
  validates_presence_of :user_id, :supplier_id
  validates_presence_of :reference, :unless => :was_draft?
  validates_inclusion_of :status, :in => [ STATUS_DRAFT, STATUS_CONFIRMED, STATUS_PROCESSING, STATUS_COMPLETED, STATUS_CANCELLED ]
  validates_inclusion_of :status, :in => [ STATUS_DRAFT, STATUS_CONFIRMED ], :if => :was_draft?
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED, STATUS_PROCESSING, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_confirmed?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_COMPLETED ], :if => :was_completed?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED ], :if => :was_cancelled?
  validates_associated :purchase_order_supplies
  
  def purchase_order_supplies_attributes=(purchase_order_supplies_attributes)
    purchase_order_supplies_attributes.each do |attributes|
      purchase_order_supplies.build(attributes)
    end
  end
  
#  def choices_attributes=(choices_attributes)
#    choices_attributes.each do |attributes|
#      purchase_order.build(attributes)
#    end
#  end
  
  def draft?
    status == STATUS_DRAFT
  end

  def confirmed?
    status == STATUS_CONFIRMED
  end
  
  def processing?
    status == STATUS_PROCESSING
  end
  
  def completed?
    status == STATUS_COMPLETED
  end
  
  def was_draft?
    status_was == STATUS_DRAFT
  end
  
  def was_confirmed?
    status_was == STATUS_CONFIRMED
  end
  
  def was_processing?
    status_was == STATUS_PROCESSING
  end
  
  def can_be_confirmed?
    was_draft?
  end
  
  def can_be_processed?
    was_confirmed? 
  end

  def can_be_completed?
    was_processing?
  end
  
  def can_be_cancelled?
    was_draft? or was_confirmed?
  end
  
  def confirm
    if can_be_confirmed?
      self.confirmed_at = Time.now
      self.status = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def process
    if can_be_processed?
      self.processing_since = Time.now
      self.status = STATUS_PROCESSING
      self.save
    else
      false
    end
  end
  
  def complete
    if can_be_completed?
      self.completed_at = Time.now
      self.status = STATUS_COMPLETED
      self.save
    else
      false
    end
  end
  
  def cancel(attributes)
    if can_be_cancelled?
      self.attributes = attributes
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
end
