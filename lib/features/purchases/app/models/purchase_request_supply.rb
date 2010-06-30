class PurchaseRequestSupply < ActiveRecord::Base
  
  has_many  :request_order_supplies
  has_many  :purchase_order_supplies, :through => :request_order_supplies
  
  has_one   :confirmed_purchase_order_supply, :through => :request_order_supplies, :include => 'purchase_order', :conditions => [ 'purchase_orders.status IS NOT NULL' ],  :source => :purchase_order_supply
  
  has_many  :draft_purchase_order_supplies, :through => :request_order_supplies, :include => 'purchase_order', :conditions => [ 'purchase_orders.status IS NULL'],  :source => :purchase_order_supply

  belongs_to :purchase_request
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => 'cancelled_by'
  
  validates_presence_of :supply_id
  validates_persistence_of :expected_delivery_date
  
  validates_numericality_of :expected_quantity, :greater_than => 0
  validates_date :expected_delivery_date, :after => Date.today, :if => :new_record?
  
  STATUS_UNTREATED = "untreated"
  
  named_scope :actives, :conditions => [ 'status = ?', PurchaseRequestSupply::STATUS_UNTREATED ]

  
  def check_request_supply_status
    return PurchaseRequest::STATUS_UNTREATED if self.untreated?  
    return PurchaseRequest::STATUS_DURING_TREATMENT if self.during_treatment? 
    return PurchaseRequest::STATUS_TREATED if self.treated? 
  end
  
  def check_order_supply_status
    #TODO
  end
  
  def can_be_cancelled?
    cancelled? ? false : true
  end
  
  def cancelled?
   self.cancelled_at || self.purchase_request.cancelled? 
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def untreated?
    !self.confirmed_purchase_order_supply && self.draft_purchase_order_supplies.empty?
  end
  
  def during_treatment?
    self.draft_purchase_order_supplies.any? && !self.confirmed_purchase_order_supply
  end
  
  def treated?
    self.confirmed_purchase_order_supply
  end
  
  def self.get_all_pending_purchase_request_supplies
    all_purchase_request_supplies = PurchaseRequestSupply.all
    purchase_request_supplies = []
    for purchase_request_supply in all_purchase_request_supplies
      if !purchase_request_supply.cancelled? and purchase_request_supply.untreated?
        purchase_request_supplies << purchase_request_supply
      end
    end
  end

  def self.get_all_suppliers_for_all_purchase_request_supplies
    purchase_request_supplies = get_all_pending_purchase_request_supplies
    suppliers_array = []
    for purchase_request_supply in purchase_request_supplies
      suppliers_array += purchase_request_supply.supply.suppliers
    end
    if !suppliers_array.empty?
      suppliers_array = suppliers_array.uniq.sort_by{ |supplier| supplier.merge_purchase_request_supplies.count }
      suppliers_array = suppliers_array.reverse{ |supplier| supplier.merge_purchase_request_supplies.count }
    else
      suppliers_array
    end
  end
  
#  def validate
#    !purchase_order_supplies.empty?
#  end

end
