class Order < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :establishment
  has_one :commercial_order
  has_one :facturation_order
  has_many :orders_steps, :class_name => "OrdersSteps"
  
  validates_presence_of :order_type
  validates_presence_of :establishment
  validates_presence_of :customer
  
  ## Create all orders_steps after create
  def after_create
    self.order_type.activated_steps.each {|step| OrdersSteps.create(:order_id => self.id, :step_id => step.id, :status => "unstarted")}
  end
  
  ## Return current step order
  def step
    OrdersSteps.find_by_order_id_and_status(self.id, "in_progress").nil? ? OrdersSteps.find_by_order_id_and_status(self.id, "unstarted") : OrdersSteps.find_by_order_id_and_status(self.id, "in_progress").step
  end
  
  ## Return remarks's order
  def remarks
    remarks = []
    OrdersSteps.find(:all, :conditions => ["order_id = ?", self.id]).each {|order_step| order_step.remarks.each {|remark| remarks << remark} }
    remarks
  end
  
  ## Return missing elements's order
  def missing_elements
    missing_elements = []
    OrdersSteps.find(:all, :conditions => ["order_id = ?", self.id]).each {|order_step| order_step.missing_elements.each {|missing_element| missing_elements << missing_element} }
    missing_elements
  end
  
end