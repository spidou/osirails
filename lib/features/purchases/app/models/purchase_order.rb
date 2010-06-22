class PurchaseOrder < ActiveRecord::Base
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :purchase_order_supplies
  belongs_to :invoice_document, :class_name => "PurchaseDocument"
  belongs_to :delivery_document, :class_name => "PurchaseDocument"
  belongs_to :quotation_document, :class_name => "PurchaseDocument"
  belongs_to :payment_document, :class_name => "PurchaseDocument"
  belongs_to :user
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  belongs_to :supplier
  belongs_to :payment_method
  
  REQUESTS_PER_PAGE = 5
  
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
    was_confirmed?
  end
  
  def can_be_deleted?
    !new_record? and was_draft?
  end
  
  def can_be_edited?
    was_draft?
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
  
  def parcels
    parcels = []
    for purchase_order_supply in self.purchase_order_supplies
      parcels << purchase_order_supply.parcel
    end
    parcels.uniq
  end
  
  def total_price
    total_price = 0
    for purchase_order_supply in purchase_order_supplies
      if purchase_order_supply.status != PurchaseOrderSupply::STATUS_CANCELLED
        supplier_supply = SupplierSupply.find_by_supply_id_and_supplier_id(purchase_order_supply.supply_id, supplier_id)
        total_price += (purchase_order_supply.quantity * (supplier_supply.fob_unit_price * ((100+supplier_supply.taxes)/100)))
      end
    end
    total_price
  end
  
  def lead_time
    lead_time = 0
    for purchase_order_supply in purchase_order_supplies
      supplier_supply_lead_time = purchase_order_supply.supply.supplier_supplies.find_by_supplier_id(supplier_id).lead_time
      if lead_time < supplier_supply_lead_time
        lead_time = supplier_supply_lead_time
      end
    end
    lead_time
  end
  
  #à vérifier après la création du formulaire permettant de créer des ordres
  def get_associated_purchase_requests
    purchase_requests = []
    for purchase_order_supply in purchase_order_supplies
      for purchase_request_supply in purchase_order_supply.purchase_request_supplies
        purchase_requests << purchase_request_supply.purchase_request
      end
    end
    purchase_requests.uniq
  end
end
