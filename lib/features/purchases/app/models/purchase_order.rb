class PurchaseOrder < ActiveRecord::Base
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference :prefix => :purchases
  
  has_many :purchase_order_supplies
  has_many :supplier_supplies, :finder_sql => 'SELECT DISTINCT s.* FROM supplier_supplies s INNER JOIN (purchase_order_supplies t) ON (t.purchase_order_id = #{id}) WHERE (s.supplier_id = #{supplier_id} AND s.supply_id = t.supply_id)'
  has_many :parcel_items, :through => :purchase_order_supplies
  has_many :parcels, :finder_sql => '
                                    SELECT DISTINCT parcels.*
                                    FROM purchase_orders 
                                    INNER JOIN purchase_order_supplies
                                    ON #{id} = purchase_order_supplies.purchase_order_id
                                    INNER JOIN parcel_items
                                    ON purchase_order_supplies.id = parcel_items.purchase_order_supply_id
                                    INNER JOIN parcels
                                    ON parcel_items.parcel_id = parcels.id
                                    ORDER BY parcels.status, parcels.cancelled_at DESC, parcels.received_on DESC, parcels.received_by_forwarder_on DESC, parcels.shipped_on DESC, parcels.processing_by_supplier_since DESC
                                    '
  
  belongs_to :invoice_document, :class_name => "PurchaseDocument"
  belongs_to :quotation_document, :class_name => "PurchaseDocument"
  belongs_to :user
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  belongs_to :supplier
  
  REQUESTS_PER_PAGE = 5
  
  STATUS_DRAFT = 1
  STATUS_CONFIRMED = 2
  STATUS_PROCESSING_BY_SUPPLIER = 3
  STATUS_COMPLETED = 4
  STATUS_CANCELLED = 5
    
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supplier]               = "Fournisseur :"
  @@form_labels[:employee]               = "Demandeur :"
  @@form_labels[:user]                   = "Créateur de la demande :"
  @@form_labels[:reference]              = "Référence :"
  @@form_labels[:statut]                 = "Status :"
  @@form_labels[:cancelled_comment]      = "Veuillez saisir la raison de l'annulation :"
  
  validates_presence_of :user_id, :supplier_id
  validates_presence_of :cancelled_comment, :if => :cancelled_by, :message => "Veuillez préciser la raison pour laquelle vous annulez cet ordre d'achats"
  
  validates_length_of :purchase_order_supplies, :minimum => 1, :message => "Veuillez selectionner au moins une matiere premiere ou un consommable"
  
  validate :validates_length_of_purchase_order_supplies_if_should_destroy , :unless => :new_record?
  
  validates_inclusion_of :status, :in => [ STATUS_DRAFT ], :if => :new_record?
  validates_inclusion_of :status, :in => [ STATUS_DRAFT, STATUS_CONFIRMED ], :if => :was_draft?
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED, STATUS_PROCESSING_BY_SUPPLIER, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_confirmed?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING_BY_SUPPLIER, STATUS_CANCELLED, STATUS_COMPLETED ], :if => :was_processing_by_supplier?
  validates_inclusion_of :status, :in => [ STATUS_COMPLETED ], :if => :was_completed?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED ], :if => :was_cancelled?
  
  validates_associated :purchase_order_supplies, :supplier_supplies
  
  validates_associated :invoice_document, :if => :completed?
  validates_associated :quotation_document, :if => :confirmed?
  
  named_scope :pending, :conditions => ["purchase_orders.status = ? OR purchase_orders.status = ? OR purchase_orders.status = ?", STATUS_DRAFT, STATUS_CONFIRMED, STATUS_PROCESSING_BY_SUPPLIER ],
                        :order => "purchase_orders.created_at DESC"                        
  named_scope :completed, :conditions => ["purchase_orders.status = ?", STATUS_COMPLETED ],
                        :order => "purchase_orders.completed_on DESC"
  named_scope :closed, :conditions => ["purchase_orders.status = ? OR purchase_orders.status = ?", STATUS_COMPLETED, STATUS_CANCELLED ],
                        :order => "purchase_orders.cancelled_at DESC, purchase_orders.completed_on DESC"
  
  before_validation :build_supplier_supplies, :build_associated_request_order_supplies
  before_validation :update_reference_only_on_confirm
    
  after_save  :save_purchase_order_supplies, :save_supplier_supplies, :save_request_order_supplies
  after_save  :destroy_request_order_supplies_deselected
  after_save  :save_quotation_document, :if => :confirmed?
  after_save  :save_invoice_document, :if => :completed?
  
  def not_cancelled_purchase_order_supplies
    tab_not_cancelled_purchase_order_supplies = []
    for purchase_order_supply in purchase_order_supplies
      tab_not_cancelled_purchase_order_supplies.push purchase_order_supply unless purchase_order_supply.cancelled?
    end 
    tab_not_cancelled_purchase_order_supplies
  end
  
  def are_all_purchase_order_supplies_treated?
    return false if not_cancelled_purchase_order_supplies.empty?
    for purchase_order_supply in not_cancelled_purchase_order_supplies
      return false unless purchase_order_supply.treated?
    end
    return true
  end
  
  def destroy_request_order_supplies_deselected
    purchase_order_supplies.each do |e|
      if e.purchase_request_supplies_deselected_ids
        e.purchase_request_supplies_deselected_ids.split(';').each do |s|
          if (s != '' && purchase_request_supply = PurchaseRequestSupply.find(s))
            request_order_supply = e.request_order_supplies.detect{|t| t.purchase_request_supply_id == s.to_i}
            request_order_supply.destroy if request_order_supply
          end
        end
      end
    end
  end
  
  def validates_length_of_purchase_order_supplies_if_should_destroy
    result = 0;
    for purchase_order_supply in purchase_order_supplies
      result += purchase_order_supply.should_destroy.to_i
    end
    errors.add(:parcel_items, "Veuillez garder au moins une fourniture") if result == purchase_order_supplies.size
  end
  
  def build_associated_request_order_supplies
    purchase_order_supplies.each do |e|
      if e.purchase_request_supplies_ids
        e.purchase_request_supplies_ids.split(';').each do |s|
          if (s != '' && purchase_request_supply = PurchaseRequestSupply.find(s))
            e.request_order_supplies.build(:purchase_request_supply_id => purchase_request_supply.id) unless
            e.request_order_supplies.detect{|t| t.purchase_request_supply_id == s.to_i}
          end
        end
      end
    end
  end
  
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

  def save_request_order_supplies
    purchase_order_supplies.each do |e|
      e.request_order_supplies.each do |s|
        s.save(false)
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
      if e.should_destroy.to_i != 1
        e.save(false)
      else
        e.destroy()
      end
    end
  end
  
  def update_reference_only_on_confirm
    update_reference if (confirmed_on and !confirmed_on_was)
  end
  
  def purchase_order_supply_attributes=(purchase_order_supply_attributes)
    purchase_order_supply_attributes.each do |attributes|
      if attributes[:id].blank?
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
  
  def processing_by_supplier?
    status == STATUS_PROCESSING_BY_SUPPLIER
  end
  
  def completed?
    status == STATUS_COMPLETED
  end
  
  def cancelled?
    counter = 0
    for purchase_order_supply in purchase_order_supplies
      counter += 1 if purchase_order_supply.cancelled?
    end
    return true if counter == purchase_order_supplies.size and counter != 0
    status == STATUS_CANCELLED
  end
  
  def was_draft?
    status_was == STATUS_DRAFT
  end
  
  def was_confirmed?
    status_was == STATUS_CONFIRMED
  end
  
  def was_processing_by_supplier?
    status_was == STATUS_PROCESSING_BY_SUPPLIER
  end
  
  def was_completed?
    status_was == STATUS_COMPLETED
  end
  
  def was_cancelled?
    counter = 0
    for purchase_order_supply in purchase_order_supplies
      counter += 1 if purchase_order_supply.was_cancelled?
    end
    return true if counter == purchase_order_supplies.size
    status_was == STATUS_CANCELLED
  end
  
  def can_be_confirmed?
    was_draft? and !was_cancelled?
  end
  
  def can_be_processed_by_supplier?
    was_confirmed?
  end
  
  def can_be_completed?
    (was_confirmed? || was_processing_by_supplier?) && are_all_purchase_order_supplies_treated?
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
  
  def can_be_confirmed_with_purchase_request_supplies_associated?
    for purchase_order_supply in purchase_order_supplies
      for purchase_request_supply in purchase_order_supply.purchase_request_supplies
        if purchase_request_supply.confirmed_purchase_order_supply
          errors.add(:purchase_order_supplies, "Certains &eacute;l&eacute;ments emp&ecirc;chent la confirmation de votre ordre d'achat")
          return false 
        end
      end
    end
    return true
  end

  def confirm
    if can_be_confirmed? && can_be_confirmed_with_purchase_request_supplies_associated? 
      self.confirmed_on = Time.now
      self.status = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def process_by_supplier
    if can_be_processed_by_supplier?
      self.processing_by_supplier_since = Time.now
      self.status = STATUS_PROCESSING_BY_SUPPLIER
      self.save
    else
      false
    end
  end
  
  def complete
    if can_be_completed?
      self.completed_on = Time.now
      self.status = STATUS_COMPLETED
      self.save
    else
      false
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
  def total_price(cancelled = false)
    total_price = 0
    total_price_cancelled = 0
    for purchase_order_supply in purchase_order_supplies
      supplier_supply = purchase_order_supply.get_supplier_supply
      if !purchase_order_supply.cancelled?
        total_price += (purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100+supplier_supply.taxes.to_f)/100)))
      else
        total_price_cancelled += (purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100+supplier_supply.taxes.to_f)/100)))
      end
    end
    return total_price_cancelled+total_price if cancelled
    total_price
  end
  
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
    self.purchase_order_supplies = []
    for purchase_request_supply in list_of_supplies
      purchase_request_supply_tmp = PurchaseOrderSupply.new(:supply_id => purchase_request_supply.supply_id,
                                                            :quantity => purchase_request_supply.expected_quantity,
                                                            :taxes => SupplierSupply.find_by_supply_id_and_supplier_id(purchase_request_supply.supply_id, self.supplier_id).taxes,
                                                            :fob_unit_price => SupplierSupply.find_by_supply_id_and_supplier_id(purchase_request_supply.supply_id, self.supplier_id).fob_unit_price)
      purchase_request_supply_tmp.unconfirmed_purchase_request_supplies.each do |e|
        purchase_request_supply_tmp.request_order_supplies.build(:purchase_request_supply_id => e.id)
      end
      self.purchase_order_supplies.push purchase_request_supply_tmp
    end
    self.purchase_order_supplies
  end
  
  def is_remaining_quantity_for_parcel?
    for purchase_order_supply in purchase_order_supplies
      return true if purchase_order_supply.remaining_quantity_for_parcel > 0
    end
    false
  end
  
  def can_add_parcel?
    (status == STATUS_CONFIRMED or status == STATUS_PROCESSING_BY_SUPPLIER) and is_remaining_quantity_for_parcel? and !cancelled?
  end
  
  def quotation_document_attributes=(quotation_document_attributes)
    self.quotation_document = PurchaseDocument.new(quotation_document_attributes.first)
  end
  
  def save_quotation_document
    quotation_document.save if quotation_document
  end
  
  def invoice_document_attributes=(invoice_document_attributes)
    self.invoice_document = PurchaseDocument.new(invoice_document_attributes.first)
  end
  
  def save_invoice_document
    invoice_document.save
  end
  
  def put_purchase_order_status_to_cancelled
    self.purchase_order_supplies.reload
    if cancelled?
      self.cancelled_comment = "" unless status == STATUS_CANCELLED
      self.cancel unless status == STATUS_CANCELLED
    end
  end
end

