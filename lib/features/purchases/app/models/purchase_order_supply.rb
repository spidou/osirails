class PurchaseOrderSupply < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :request_order_supplies
  has_many :purchase_request_supplies, :through => :request_order_supplies
  
  has_many :parcel_items
  has_many :parcels, :through => :parcel_items, :order => 'parcels.status, parcels.cancelled_at DESC, parcels.received_on DESC, parcels.received_by_forwarder_on DESC, parcels.shipped_on DESC, parcels.processing_by_supplier_since DESC'
  has_one  :issued_parcel_item, :class_name => "ParcelItem", :foreign_key => :issue_purchase_order_supply_id
  
  belongs_to :purchase_order
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id
  
  attr_accessor :purchase_request_supplies_ids
  attr_accessor :purchase_request_supplies_deselected_ids
  attr_accessor :should_destroy
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:cancelled_comment] = "Veuillez saisir la raison de l'annulation :"
  
  validates_presence_of :supply_id, :supplier_designation, :supplier_reference
  validates_presence_of :cancelled_by_id, :cancelled_comment, :if => :cancelled_at
  
  validates_numericality_of :quantity, :fob_unit_price , :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0
  
  validates_associated :request_order_supplies
  
  after_save  :automatically_put_purchase_order_status_to_cancelled , :unless => :new_record?
  after_save  :purchase_order_supply_associated_to_report, :unless => :new_record?
  after_save  :automatically_put_parcel_items_status_to_cancelled, :unless => :new_record?
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def automatically_put_parcel_items_status_to_cancelled
    for parcel_item in parcel_items
      if parcel_item.can_be_cancelled? && canceller
        parcel_item.cancelled_comment = "cancelled"
        parcel_item.canceller = canceller
        parcel_item.cancel 
      end
    end
  end
  
  def purchase_order_supply_associated_to_report
    if (issued_item = issued_parcel_item) && canceller
      issued_item.issue_purchase_order_supply_id = nil
      issued_item.must_be_reshipped = nil
      issued_item.issued_at = nil
      issued_item.issues_quantity = nil
      issued_item.issues_comment = nil
      issued_item.send_back_to_supplier = nil
      issued_item.save
    end
  end
  
  def automatically_put_purchase_order_status_to_cancelled
    self.purchase_order.put_purchase_order_status_to_cancelled
  end
  
  def remaining_quantity_for_parcel
    result = 0
    for parcel_item in parcel_items
      result += (parcel_item.quantity.to_i)  unless parcel_item.parcel.cancelled? || parcel_item.cancelled?
    end
    quantity - result
  end
  
  def verify_all_parcel_items_are_received?
    for parcel_item in parcel_items
      return false unless parcel_item.parcel.cancelled? || parcel_item.cancelled? || parcel_item.parcel.received?
    end
    return true
  end
  
  def count_quantity_in_parcel_items
    parcel_items.reject{ |i| i.parcel.cancelled? or i.cancelled? }.collect{ |i| i.quantity.to_i }.sum
  end
  
  def untreated?
    parcel_items.empty?
  end
  
  def processing_by_supplier?
    parcel_items.any? && (count_quantity_in_parcel_items != quantity || !verify_all_parcel_items_are_received?)
  end
  
  def treated?
    parcel_items.any? && count_quantity_in_parcel_items == quantity && verify_all_parcel_items_are_received?
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def not_receive_associated_parcels?
    for parcel_item in parcel_items
      return false if parcel_item.parcel.status == Parcel::STATUS_RECEIVED
    end
    return true
  end
  
  def can_be_cancelled?
    !new_record? && !purchase_order.draft? && !purchase_order.completed? && ((untreated? && !was_cancelled? && !purchase_order.cancelled?) || (not_receive_associated_parcels? && !cancelled? && !purchase_order.cancelled?))
  end
  
  def can_be_deleted?
    new_record? or purchase_order.draft?
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
  
  def get_supplier_supply(supplier_id = nil, supply_id = nil)
    supplier_id ||= purchase_order.supplier_id if purchase_order
    supply_id   ||= supply.id if supply
    SupplierSupply.find_by_supplier_id_and_supply_id(supplier_id, supply_id)
  end
  
  def get_unit_price_including_tax(supplier_id = purchase_order.supplier, supply_id = supply.id)
    return 0 unless get_supplier_supply(supplier_id, supply_id)
    supplier_supply = get_supplier_supply(supplier_id, supply_id)
    taxes = supplier_supply.taxes
    if fob_unit_price
      fob_unit_price
    else
      fob_unit_price = supplier_supply.unit_price
    end
    supplier_supply.fob_unit_price * ( 1 + ( taxes / 100.0 ) )
  end
  
  def get_purchase_order_supply_total
    quantity.to_f * get_unit_price_including_tax.to_f
  end
  
  def get_taxes
    return taxes if taxes
    return 0 unless get_supplier_supply
    get_supplier_supply.taxes
  end
  
  def not_cancelled_purchase_request_supplies
    PurchaseRequestSupply.all(:include => :purchase_request, :conditions => ['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL', supply_id])
  end
  
  def unconfirmed_purchase_request_supplies
    res = []
    for request_supply in not_cancelled_purchase_request_supplies
      if new_record?
        res.push(request_supply) unless request_supply.confirmed_purchase_order_supply
      else
        res.push(request_supply) if self.purchase_request_supplies.detect{|t| t.id == request_supply.id} || !request_supply.confirmed_purchase_order_supply
      end
    end
    res
  end
  
  def can_add_request_supply_id(id)
    if purchase_request_supplies_deselected_ids
      purchase_request_supplies_deselected_ids.split(';').each do |s|
        return false if (s != '' && id.to_i == s.to_i)
      end 
    end
    return true
  end
  
  def get_purchase_request_supplies_ids
    res = []
    unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
      if request_order_supplies.detect{ |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } and can_add_request_supply_id(purchase_request_supply.id)
        res << purchase_request_supply.id
      end
    end
    res.join(";")
  end
  
  def boolean_checked(purchase_request_supply)
    return true if request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } && can_add_request_supply_id(purchase_request_supply.id)
    return false
  end
  
  def integer_checked(purchase_request_supply)
    return 1 if request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } && can_add_request_supply_id(purchase_request_supply.id)
    return 0
  end
  
  def get_purchase_order_supply_total
    quantity.to_f * get_unit_price_including_tax.to_f
  end
  
  def are_parcel_or_parcel_items_all_cancelled?
    for parcel_item in parcel_items
      return false if !parcel_item.was_cancelled? || !parcel_item.parcel.was_cancelled?
    end
    return true
  end
end
