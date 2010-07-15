class Parcel < ActiveRecord::Base

  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference :prefix => :purchases  
    
  has_many :parcel_items
  has_many :purchase_order_supplies, :through => "parcel_items"
  
  belongs_to :delivery_document, :class_name => "PurchaseDocument"
  
  has_attached_file :delivery_document, 
                    :styles => { :thumb => "120x120" },
                    :path   => ":rails_root/assets/purchases/delivery_document/:id.:style",
                    :url    => "/parcels/:id.:extension"
  
  STATUS_PROCESSING_BY_SUPPLIER = nil || ""
  STATUS_SHIPPED = "shipped"
  STATUS_RECEIVED_BY_FORWARDER = "received_by_forwarder"
  STATUS_RECEIVED = "received"
  STATUS_CANCELLED = "cancel"
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:shipped_at]                              = "Exp&eacute;di&eacute; le :"
  @@form_labels[:conveyance]                              = "Par :"
  @@form_labels[:previsional_delivery_date]               = "Date de livraison prévue du colis :"
  @@form_labels[:received_by_forwarder_at]                = "Reçu par le transitaire le :"
  @@form_labels[:awaiting_pick_up]                        = "En attente de récupération :"
  @@form_labels[:received_at]                             = "Reçu le :"
  @@form_labels[:delivery_document]                       = "Bon de livraison :"
  @@form_labels[:cancelled_comment]                       = "Veuillez saisir la raison de l'annulation :"
  
  validates_date :shipped_at, :on_or_after => :processing_by_supplier_since, :if => :shipped?
  validates_date :received_by_forwarder_at, :on_or_after => :shipped_at, :if => :received_by_forwarder?
  validates_date :received_at, :on_or_after => :received_by_forwarder_at, :if => :received?
  
  attr_accessor :delivery_document
  
  validates_presence_of :conveyance , :if => :shipped?
  validates_presence_of :cancelled_comment, :if => :cancelled_at

  validates_inclusion_of :status, :in => [ STATUS_RECEIVED ], :if => :was_received?  
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED, STATUS_CANCELLED], :if => :was_received_by_forwarder?
  validates_inclusion_of :status, :in => [ STATUS_SHIPPED, STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED, STATUS_CANCELLED ], :if => :was_shipped?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING_BY_SUPPLIER, STATUS_SHIPPED, STATUS_CANCELLED ], :if => :was_processing_by_supplier?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING_BY_SUPPLIER, STATUS_SHIPPED, STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED ], :if => :new_record?
    
  validates_associated :parcel_items
  validate :validates_lenght_of_parcel_item_selected, :if => :new_record?
  
  before_validation_on_create :update_reference
  after_create  :delete_unselected_parcel_items
  after_save    :deduct_purchase_order_status
  
  def get_purchase_order
    self.parcel_items.first.purchase_order_supply.purchase_order if self.parcel_items.first  
  end
  
  def deduct_purchase_order_status
    purchase_order = get_purchase_order
    if purchase_order.verify_all_purchase_order_supplies_are_treated
      purchase_order.complete unless purchase_order.was_completed?
    else
      purchase_order.process unless purchase_order.was_processing? 
    end
  end
  
  def validates_lenght_of_parcel_item_selected
    result = 0;
    for parcel_item in parcel_items
      result += parcel_item.selected.to_i
    end
    errors.add(:parcel_items, "Veuillez selectionner au moins une fourniture dans votre colis") if result == 0
  end
  
  def delete_unselected_parcel_items
    for parcel_item in parcel_items
      parcel_item.destroy if parcel_item.selected.to_i == 0
    end
  end
  
  def processing_by_supplier?
    status == STATUS_PROCESSING_BY_SUPPLIER
  end

  def shipped?
    status == STATUS_SHIPPED
  end

  def received_by_forwarder?
    status == STATUS_RECEIVED_BY_FORWARDER
  end

  def received?
    status == STATUS_RECEIVED
  end

  def cancelled?
    counter = 0
    for parcel_item in parcel_items
      counter += 1 if parcel_item.cancelled?
    end
    return true if counter == parcel_items.size
    status == STATUS_CANCELLED
  end

  def was_processing_by_supplier?
    status_was == STATUS_PROCESSING_BY_SUPPLIER
  end

  def was_shipped?
    status_was == STATUS_SHIPPED
  end

  def was_received_by_forwarder?
    status_was == STATUS_RECEIVED_BY_FORWARDER
  end

  def was_received?
    status_was == STATUS_RECEIVED
  end

  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def can_be_processing_with_associated_parcel_items?
    for parcel_item in parcel_items
      return false if parcel_item.quantity > parcel_item.purchase_order_supply.remaining_quantity_for_parcel
    end
    return true
  end
  
  def can_be_processing_by_supplier?
    new_record?
  end

  def can_be_shipped?
    processing_by_supplier?
  end

  def can_be_received_by_forwarder?
    shipped?
  end
  
  def can_be_received?
    new_record? or was_received_by_forwarder?
  end
  
  def can_be_cancelled?
    !was_cancelled? and !new_record? and !was_received?
  end
  
  def process_by_supplier
    if can_be_processing_by_supplier?
      self.status = STATUS_PROCESSING_BY_SUPPLIER
      self.save
    else
      false
    end
  end
  
  def ship
    if can_be_shipped?
      self.status = STATUS_SHIPPED
      self.save
    else
      false
    end
  end

  def receive_by_forwarder
    if can_be_received_by_forwarder?
      self.status = STATUS_RECEIVED_BY_FORWARDER
      self.save
    else
      false
    end
  end

  def receive
    if can_be_received?
      self.status = STATUS_RECEIVED
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
  
  def parcel_item_attributes=(parcel_item_attributes)
    parcel_item_attributes.each do |attributes|
      parcel_items.build(attributes) if attributes[:purchase_order_supply_id]
    end
  end

  def build_parcel_items_with_purchase_order_supplies(purchase_order_supplies)
    for purchase_order_supply in purchase_order_supplies
      if !purchase_order_supply.cancelled? && purchase_order_supply.remaining_quantity_for_parcel != 0 &&
         !parcel_items.detect { |t| t.purchase_order_supply_id == purchase_order_supply.id } 
         parcel_items.build(:purchase_order_supply_id => purchase_order_supply.id, :quantity => purchase_order_supply.remaining_quantity_for_parcel, :selected => 0)
      end
    end
    parcel_items
  end
  
  def delivery_document_attributes=(delivery_document_attributes)
    delivery_document_attributes.each do |attributes|
      purchase_document = PurchaseDocument.new(attributes)
    end
  end
end

