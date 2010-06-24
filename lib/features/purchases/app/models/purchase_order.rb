class PurchaseOrder < ActiveRecord::Base
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :purchase_order_supplies
  has_many :supplier_supplies, :finder_sql => 'SELECT DISTINCT s.* FROM supplier_supplies s INNER JOIN (purchase_order_supplies t) ON (t.purchase_order_id = #{id}) WHERE (s.supplier_id = #{supplier_id} AND s.supply_id = t.supply_id)'                                                  
  
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
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supplier]               = "Fournisseur :"
  @@form_labels[:employee]               = "Demandeur :"
  @@form_labels[:user]                   = "Créateur de la demande :"
  @@form_labels[:reference]              = "Référence :"
  @@form_labels[:statut]                 = "Status :"
  
  validates_presence_of :user_id, :supplier_id
  validates_presence_of :reference, :unless => :was_draft?
  
  validates_length_of :purchase_order_supplies, :minimum => 1, :message => "Veuillez selectionner au moins une matiere premiere ou un consommable"
  
  validates_inclusion_of :status, :in => [ STATUS_DRAFT, STATUS_CONFIRMED, STATUS_PROCESSING, STATUS_COMPLETED, STATUS_CANCELLED ]
  validates_inclusion_of :status, :in => [ STATUS_DRAFT, STATUS_CONFIRMED ], :if => :was_draft?
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED, STATUS_PROCESSING, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_confirmed?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_COMPLETED ], :if => :was_completed?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED ], :if => :was_cancelled?
  
  validates_associated :purchase_order_supplies, :supplier_supplies
  
  before_validation_on_create :build_supplier_supplies
  after_save  :save_purchase_order_supplies, :save_supplier_supplies
  
  def build_supplier_supplies
    purchase_order_supplies.each do |e|
        if !SupplierSupply.find_by_supply_id_and_supplier_id(e.supply_id, supplier_id)
          supplier_supplies.build(:supplier_id => supplier_id,
                                  :supply_id => e.supply_id,
                                  :supplier_reference => e.supplier_reference,
                                  :supplier_designation => e.supplier_designation,
                                  :fob_unit_price => e.fob_unit_price,
                                  :taxes => e.taxes)
        end
    end
  end
  
  def save_supplier_supplies
    supplier_supplies.each do |e|
      e.save(false)
    end
  end
   
  def save_purchase_order_supplies
    purchase_order_supplies.each do |e|
      e.save(false)
    end
  end
  
  def purchase_order_supply_attributes=(purchase_order_supply_attributes)
    purchase_order_supply_attributes.each do |attributes|
      if attributes[id].blank?
        purchase_order_supplies.build(attributes)
      else
        purchase_order_supply = purchase_order_supplies.detect { |t| t.id == attributes[:id].to_i }
        purchase_order_supply.attributes = attributes
      end
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
  
  def was_completed?
    status_was == STATUS_COMPLETED
  end

  def was_cancelled?
    status_was == STATUS_CANCELLED
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
  
  def total_price(cancelled = false)
    total_price = 0
    total_price_cancelled = 0
    for purchase_order_supply in purchase_order_supplies
      supplier_supply = purchase_order_supply.get_supplier_supply
      if purchase_order_supply.status != PurchaseOrderSupply::STATUS_CANCELLED
        total_price += (purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100+supplier_supply.taxes.to_f)/100)))
      else
        total_price_cancelled += (purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100+supplier_supply.taxes.to_f)/100)))
      end
    end
    return total_price_cancelled if cancelled
    total_price
  end
  
  def lead_time
    lead_time = 0
    for purchase_order_supply in purchase_order_supplies
      supplier_supply_lead_time = purchase_order_supply.get_supplier_supply.lead_time || 0
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
  
  def build_with_purchase_request_supplies(list_of_supplies)
    list_of_purchase_request_supplies = []
    for purchase_request_supply in list_of_supplies
      list_of_purchase_request_supplies << PurchaseOrderSupply.new(:supply_id => purchase_request_supply.supply_id, 
      :quantity => purchase_request_supply.expected_quantity,
      :taxes => SupplierSupply.find_by_supply_id_and_supplier_id(purchase_request_supply.supply_id, self.supplier_id).taxes, 
      :fob_unit_price => SupplierSupply.find_by_supply_id_and_supplier_id(purchase_request_supply.supply_id, self.supplier_id).fob_unit_price)
    end
    self.purchase_order_supplies = list_of_purchase_request_supplies
  end
  
end
