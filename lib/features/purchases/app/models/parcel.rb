class Parcel < ActiveRecord::Base

  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference :prefix => :purchases  
    
  has_many :parcel_items
  has_many :purchase_order_supplies, :through => "parcel_items"
  
  STATUS_PROCESSING = nil
  STATUS_SHIPPED = "shipped"
  STATUS_RECEIVED_BY_FORWARDER = "received_by_forwarder"
  STATUS_RECEIVED = "received"
  STATUS_CANCELLED = "cancel"
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:shipped_at]                              = "Exp&eacute;di&eacute; le :"
  @@form_labels[:conveyance]                              = "Par :"
  @@form_labels[:previsional_delivery_date]               = "Date de livraison prévue du colis :"
  
  validates_presence_of :conveyance , :if => :status
  validates_date :previsional_delivery_date, :on_or_after  => Date.today, :unless => :new_record?
  
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_SHIPPED ], :if => :was_processing?
  validates_inclusion_of :status, :in => [ STATUS_SHIPPED, STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED ], :if => :was_shipped?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED_BY_FORWARDER, STATUS_RECEIVED], :if => :was_received_by_forwarder?
  validates_inclusion_of :status, :in => [ STATUS_RECEIVED ], :if => :was_received?
  
  validates_associated :parcel_items
  validate :validates_lenght_of_parcel_item_selected, :if => :new_record?
  
  before_validation_on_create :update_reference
  after_create :delete_unselected_parcel_items
  
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
  
  def processing?
    status == STATUS_PROCESSING
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

  def was_processing?
    status_was == STATUS_PROCESSING
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
  
  def can_be_processing?
    !processing?
  end

  def can_be_shipped?
    processing?
  end

  def can_be_received_by_forwarder?
    shipped?
  end
  
  def can_be_received?
    new_record? or received_by_forwarder?
  end
  
  def can_be_cancelled?
    was_cancelled?
  end
  
  def ship
    if can_be_shipped?
      self.status = STATUS_SHIPPED
      self.shipped_at = Time.now
      self.save
    else
      false
    end
  end

  def receive_by_supplier
    if can_be_received_by_forwarder?
      self.status = STATUS_RECEIVED_BY_FORWARDER
      self.recovered_at = Time.now
      self.save
    else
      false
    end
  end

  def receive
    if can_be_received?
      self.status = STATUS_RECEIVED
      self.received_at = Time.now
      self.save
    else
      false
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.status = STATUS_CANCELLED
      self.cancelled_at = Time.now
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
  
end

