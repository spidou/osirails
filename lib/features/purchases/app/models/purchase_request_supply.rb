class PurchaseRequestSupply < ActiveRecord::Base
  STATUS_UNTREATED = "untreated"
  
  has_many :quotation_request_purchase_request_supplies
  has_many :quotation_request_supplies, :through => :quotation_request_purchase_request_supplies
  has_many :quotation_purchase_request_supplies
  has_many :quotation_supplies, :through => :quotation_purchase_request_supplies
  has_many :request_order_supplies
  has_many :purchase_order_supplies, :through => :request_order_supplies
  
  has_one   :confirmed_purchase_order_supply, :through    => :request_order_supplies,
                                              :include    => 'purchase_order',
                                              :conditions => [ 'purchase_orders.status > ?', PurchaseOrder::STATUS_DRAFT ],
                                              :source     => :purchase_order_supply
  
  has_many  :draft_purchase_order_supplies,   :through    => :request_order_supplies,
                                              :include    => 'purchase_order',
                                              :conditions => [ 'purchase_orders.status = ?', PurchaseOrder::STATUS_DRAFT ],
                                              :source     => :purchase_order_supply
  belongs_to :purchase_priority
  belongs_to :purchase_request
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id

  validates_presence_of :purchase_priority_id
  validates_presence_of :designation, :unless => :supply
  validates_presence_of :purchase_priority, :if => :purchase_priority_id
  validates_presence_of :supply, :if => :supply_id
  validates_presence_of :cancelled_by_id, :if => :cancelled_at
  validates_presence_of :canceller, :if => :cancelled_by_id
  
  validates_persistence_of :expected_delivery_date
  
  validates_numericality_of :expected_quantity, :greater_than => 0
  validates_date :expected_delivery_date, :after => Date.today, :if => :new_record?

  named_scope :sorted_by_priority_and_expected_delivery_date, :order => "purchase_priority_id, expected_delivery_date"
  
  def reference
    self.supply ? self.supply.reference : "-"
  end
  
  def designation
    self.supply ? self.supply.designation : self[:designation] 
  end
  
  def unit_mass
    self.supply ? self.supply.unit_mass : "-"
  end
  
  def measure
    self.supply ? self.supply.measure : "-"
  end
  
  def threshold
    self.supply ? self.supply.threshold : "-"
  end
  
  def stock_quantity
    self.supply ? self.supply.stock_quantity : "-"
  end
  
  def stock_quantity_at_last_inventory
    self.supply ? self.supply.stock_quantity_at_last_inventory : "-"
  end
  
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
    !confirmed_purchase_order_supply.nil?
  end
  
  def self.all_pending_purchase_request_supplies
    #OPTIMIZE use a SQL statement
    PurchaseRequestSupply.all.select{ |s| !s.cancelled? and !s.treated? }
  end
  
  def self.pending_and_merged_by_supply_id
    list_of_merged_purchase_request_supply = []
    all_pending_purchase_request_supplies.group_by(&:supply_id).each do |key, value|
      quantities_sum = value.collect{ |purchase_request_supply| purchase_request_supply[:expected_quantity] }.sum
      list_of_merged_purchase_request_supply << PurchaseRequestSupply.new(:purchase_request_id => nil, :supply_id => key, :expected_quantity => quantities_sum, :expected_delivery_date => value.first.expected_delivery_date )
    end
    list_of_merged_purchase_request_supply
  end

  def self.all_suppliers_for_all_pending_purchase_request_supplies
    suppliers = all_pending_purchase_request_supplies.collect{ |s| s.supply.suppliers }.flatten.uniq
    suppliers.sort_by{ |s| s.merge_purchase_request_supplies.count }.reverse
  end
end
