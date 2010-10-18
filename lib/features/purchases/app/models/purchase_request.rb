class PurchaseRequest < ActiveRecord::Base
  STATUS_UNTREATED        = "untreated"
  STATUS_DURING_TREATMENT = "during treatment"
  STATUS_TREATED          = "treated"
  
  REQUESTS_PER_PAGE = 15
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference :prefix => :purchases
  
  has_many :purchase_request_supplies
  
  belongs_to :user
  belongs_to :employee
  belongs_to :service
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id
  
  attr_accessor :global_date
  
  validates_presence_of :user_id, :employee_id, :service_id, :reference
  validates_presence_of :user, :if => :user_id
  validates_presence_of :employee, :if => :employee_id
  validates_presence_of :service, :if => :service_id
  validates_presence_of :cancelled_by_id, :cancelled_comment, :if => :cancelled_at
  validates_presence_of :canceller, :if => :cancelled_by_id
  
  validates_length_of :purchase_request_supplies, :minimum => 1, :message => :length_of
  
  validates_persistence_of :cancelled_by_id, :cancelled_comment, :cancelled_at, :if => :cancelled_at_was
  
  validates_associated  :purchase_request_supplies
  
  before_validation_on_create :update_reference, :update_date
  after_save :save_purchase_request_supplies

  
  def update_date
    for purchase_request_supply in purchase_request_supplies
      purchase_request_supply.expected_delivery_date ||= global_date
    end
    purchase_request_supplies
  end
  
  def can_be_cancelled?
    !cancelled?
  end
  
  def cancelled?
    cancelled_at ? true : false
  end
  
  #TODO test this method
  def was_cancelled?
    cancelled_at_was ? true : false
  end
  
  def save_purchase_request_supplies
    purchase_request_supplies.each do |e|
      e.save(false)
    end
  end
  
  def purchase_request_supply_attributes=(purchase_request_supply_attributes)
    purchase_request_supply_attributes.each do |attributes|
      if attributes[:id].blank?
        purchase_request_supplies.build(attributes)
      else
        purchase_request_supply = purchase_request_supplies.detect{ |t| t.id == attributes[:id].to_i }
        purchase_request_supply.attributes = attributes
      end
    end
  end
  
  def untreated_purchase_request_supplies
    purchase_request_supplies.select(&:untreated?)
  end
  
  def during_treatment_purchase_request_supplies
    purchase_request_supplies.select(&:during_treatment?)
  end
  
  def active?
    untreated_purchase_request_supplies.size > 0 || during_treatment_purchase_request_supplies.size > 0
  end
  
  def partially_treated_purchase_request_supplies?
    purchase_request_supplies.select{|n| n.treated? || n.cancelled?}.size == purchase_request_supplies.size && purchase_request_supplies.select(&:cancelled?).any? 
  end
  
  def treated_purchase_request_supplies
    purchase_request_supplies.select(&:treated?)
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def expected_delivery_date
    purchase_request_supplies.collect(&:expected_delivery_date).sort.first
  end
    
  def purchase_orders_associated
    purchase_orders = []
    for purchase_request in purchase_request_supplies
      purchase_orders << purchase_request.confirmed_purchase_order_supply.purchase_order if  purchase_request.treated?
    end
    purchase_orders.flatten.uniq
  end
end
