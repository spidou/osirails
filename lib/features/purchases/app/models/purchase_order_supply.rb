class PurchaseOrderSupply < ActiveRecord::Base
  include ProductBase
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :request_order_supplies
  has_many :purchase_request_supplies, :through => :request_order_supplies
  has_many :purchase_delivery_items
  has_many :purchase_deliveries, :through => :purchase_delivery_items, :order => 'purchase_deliveries.status, purchase_deliveries.cancelled_at DESC, purchase_deliveries.received_on DESC, purchase_deliveries.received_by_forwarder_on DESC, purchase_deliveries.shipped_on DESC, purchase_deliveries.processing_by_supplier_since DESC'
  has_one  :issued_purchase_delivery_item, :class_name => "PurchaseDeliveryItem", :foreign_key => :issue_purchase_order_supply_id
  
  belongs_to :purchase_order
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id
  
  attr_accessor :purchase_request_supplies_ids
  attr_accessor :purchase_request_supplies_deselected_ids
  attr_accessor :should_destroy
  
  validates_presence_of :supplier_designation, :supplier_reference
  validates_presence_of :supply, :if => :supply_id
  validates_presence_of :cancelled_by_id, :cancelled_comment, :if => :cancelled_at
  validates_presence_of :canceller, :if => :cancelled_by_id
  validates_presence_of :description, :if => :comment_line
  
  validate :validates_is_not_cancelled
  
  validates_numericality_of :quantity, :fob_unit_price , :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0
  
  validates_associated :request_order_supplies
  
  after_save  :automatically_put_purchase_order_status_to_cancelled , :unless => :new_record?
  after_save  :purchase_order_supply_associated_to_report, :unless => :new_record?
  after_save  :automatically_put_purchase_delivery_items_status_to_cancelled, :unless => :new_record?
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def position
    self[:position] ||= 0
  end  
  
  #TODO test this method
  def validates_is_not_cancelled
    unless can_be_cancelled?
      errors.add(:base, message_error_for_different_supplier_between_similars) if (cancelled_comment or cancelled_by_id) and !(purchase_order.confirmed_on or purchase_order.processing_by_supplier_since)
    end
  end
  
  def automatically_put_purchase_delivery_items_status_to_cancelled
    for purchase_delivery_item in purchase_delivery_items
      if purchase_delivery_item.can_be_cancelled? && self.cancelled_by_id
        purchase_delivery_item.cancelled_comment = "cancelled"
        purchase_delivery_item.cancelled_by_id = self.cancelled_by_id
        purchase_delivery_item.cancel
      end
    end
  end
  
  def purchase_order_supply_associated_to_report
    if (issued_item = issued_purchase_delivery_item) && self.cancelled_by_id
      issued_item.issue_purchase_order_supply_id = nil
      issued_item.issued_at = nil
      issued_item.save
    end
  end
  
  def automatically_put_purchase_order_status_to_cancelled
    self.purchase_order.put_purchase_order_status_to_cancelled
  end
  
  def remaining_quantity_for_purchase_delivery
    quantity - purchase_delivery_items.reject{ |pi| pi.purchase_delivery.cancelled? || pi.cancelled? }.collect{ |pi| pi.quantity.to_i }.sum
  end
  
  def verify_all_purchase_delivery_items_are_received?
    purchase_delivery_items.each{ |pi| return false unless pi.purchase_delivery.cancelled? || pi.cancelled? || pi.purchase_delivery.received? }
    true
  end
  
  def count_quantity_in_purchase_delivery_items
    purchase_delivery_items.reject{ |i| i.purchase_delivery.cancelled? or i.cancelled? }.collect{ |i| i.quantity.to_i }.sum
  end
  
  def existing_supply?
    supply_id && !comment_line
  end
  
  def unreferenced_supply?
    !supply_id && !comment_line
  end
  
  def comment_line?
    !supply_id && comment_line
  end
  
  def untreated?
    purchase_delivery_items.empty?
  end
  
  def processing_by_supplier?
    purchase_delivery_items.any? && (count_quantity_in_purchase_delivery_items != quantity || !verify_all_purchase_delivery_items_are_received?)
  end
  
  def treated?
    purchase_delivery_items.any? && count_quantity_in_purchase_delivery_items == quantity && verify_all_purchase_delivery_items_are_received?
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def not_receive_associated_purchase_deliveries?
    purchase_delivery_items.each{ |pi| return false if pi.purchase_delivery.status == PurchaseDelivery::STATUS_RECEIVED }
    true
  end
  
  def can_be_cancelled?
    !new_record? && !purchase_order.draft? && !purchase_order.completed? && !was_cancelled? && !purchase_order.cancelled? && (untreated? || not_receive_associated_purchase_deliveries?)
  end
  
  def can_be_deleted?
    new_record? or purchase_order.draft?
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      return self.save
    end
    false
  end
  
  def vat=(vat) # for compatibility with product_base.rb
    self.taxes = vat
  end
  
  def unit_price=(unit_price) # for compatibility with product_base.rb
    self.fob_unit_price = unit_price
  end
  
  def supplier_supply(supplier_id = nil, supply_id = nil)
    supplier_id ||= purchase_order.supplier_id if purchase_order
    supply_id   ||= supply.id if supply
    SupplierSupply.find_by_supplier_id_and_supply_id(supplier_id, supply_id)
  end
  
  def fob_unit_price
    self[:fob_unit_price]
  end
    
  def unit_price_including_tax(supplier_id = purchase_order.supplier, supply_id = supply.id)
    self.fob_unit_price ||= (supplier_supply(supplier_id, supply_id) ? supplier_supply(supplier_id, supply_id).fob_unit_price.to_f : self[:fob_unit_price])
     unit_price_with_prizegiving.to_f * ( 1.0 + ( taxes.to_f / 100.0 ) )
  end
  
  def taxes
    self[:taxes]
  end
  
  def amount_taxes
    total_with_prizegiving.to_f * ( taxes.to_f / 100.0)
  end
  
  alias_method :unit_price, :fob_unit_price
  alias_method :vat, :taxes # for compatibility with product_base.rb
  
  def reference
    supply ? supply.reference : "-"
  end
  
  def designation
    supply ? supply.designation : "-"
  end
  
  def stock_quantity
    supply ? supply.stock_quantity : "-"
  end
  
  def not_cancelled_purchase_request_supplies
    if (supply_id)
      PurchaseRequestSupply.all(:include => :purchase_request, :conditions => ['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL', supply_id])
    else
      PurchaseRequestSupply.all(:include => :purchase_request, :conditions => ['purchase_request_supplies.supply_id IS NULL AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL'])
    end
  end
  
  def unconfirmed_purchase_request_supplies
    not_cancelled_purchase_request_supplies.select{ |prs| (new_record? and !prs.confirmed_purchase_order_supply) or (!new_record? and (self.purchase_request_supplies.detect{|t| t.id == prs.id} || !prs.confirmed_purchase_order_supply) ) }
  end
  
  def can_add_request_supply_id?(id)
    if purchase_request_supplies_deselected_ids
      purchase_request_supplies_deselected_ids.split(';').each do |s|
        return false if (s != '' && id.to_i == s.to_i)
      end 
    end
    true
  end
  
  def get_purchase_request_supplies_ids
    res = []
    unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
      if request_order_supplies.detect{ |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } and can_add_request_supply_id?(purchase_request_supply.id)
        res << purchase_request_supply.id
      end
    end
    res.join(";")
  end
  
  def already_associated_with_purchase_request_supply?(purchase_request_supply)
    request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } && can_add_request_supply_id?(purchase_request_supply.id) 
  end
  
  def are_purchase_delivery_or_purchase_delivery_items_all_cancelled?
    for purchase_delivery_item in purchase_delivery_items
      return false if !purchase_delivery_item.was_cancelled? || !purchase_delivery_item.purchase_delivery.was_cancelled?
    end
    true
  end
  
  def message_error_for_different_supplier_between_similars
    message_for_validates("base", "is_not_cancelled")
  end
  
  private
    def message_for_validates(attribute, error_type, restriction = "")
      I18n.t("activerecord.errors.models.#{self.class.name.tableize.singularize}.attributes.#{attribute}.#{error_type}", :restriction => restriction)
    end
end
