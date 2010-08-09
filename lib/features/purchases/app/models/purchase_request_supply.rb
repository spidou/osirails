class PurchaseRequestSupply < ActiveRecord::Base
  STATUS_UNTREATED = "untreated"
  
  has_many :request_order_supplies
  has_many :purchase_order_supplies, :through => :request_order_supplies
  has_many :draft_purchase_order_supplies, :through    => :request_order_supplies,
                                           :include    => 'purchase_order',
                                           :conditions => [ 'purchase_orders.status IS NULL'],
                                           :source     => :purchase_order_supply
  
  has_one   :confirmed_purchase_order_supply, :through    => :request_order_supplies,
                                              :include    => 'purchase_order',
                                              :conditions => [ 'purchase_orders.status > ?', PurchaseOrder::STATUS_DRAFT ],
                                              :source     => :purchase_order_supply
  
  has_many  :draft_purchase_order_supplies,   :through    => :request_order_supplies,
                                              :include    => 'purchase_order',
                                              :conditions => [ 'purchase_orders.status = ?', PurchaseOrder::STATUS_DRAFT ],
                                              :source     => :purchase_order_supply
  
  belongs_to :purchase_request
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id
  
  validates_presence_of :supply_id
  validates_persistence_of :expected_delivery_date
  
  validates_numericality_of :expected_quantity, :greater_than => 0
  validates_date :expected_delivery_date, :after => Date.today, :if => :new_record?
  
  def can_be_cancelled?
    !cancelled?
  end
  
  def cancelled?
   cancelled_at || purchase_request.cancelled? 
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def untreated?
    !confirmed_purchase_order_supply and draft_purchase_order_supplies.empty?
  end
  
  def during_treatment?
    draft_purchase_order_supplies.any? and !confirmed_purchase_order_supply
  end
  
  def treated?
    confirmed_purchase_order_supply
  end
  
  def self.get_all_pending_purchase_request_supplies
    #OPTIMIZE use a SQL statement
    PurchaseRequestSupply.all.select{ |s| !s.cancelled? and !s.treated? }
  end

  def self.get_all_suppliers_for_all_pending_purchase_request_supplies
    suppliers = get_all_pending_purchase_request_supplies.collect{ |s| s.supply.suppliers }.flatten.uniq
    suppliers.sort_by{ |s| s.merge_purchase_request_supplies.count }.reverse
  end
end
