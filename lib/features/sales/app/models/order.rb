class Order < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :establishment
  has_one :step_commercial
  has_one :step_facturation

  validates_presence_of :order_type
  #  validates_presence_of :establishment
  validates_presence_of :customer

  ## Create all orders_steps after create
  def after_create
    unless self.order_type.nil?
      self.order_type.activated_steps.each do |step|
        unless step.parent.nil?
          step.name.camelize.constantize.create(:order_id => self.id,:step_id => step.id)
        else
          name = step.name+"_order"
          name.camelize.constantize.create(:order_id => self.id,:step_id => step.id, :status => "unstarted")
        end
        ## here the code to create default commercial orders
      end
    end
  end

  ## Return a tree with activated step
  def tree
    steps =[]
    step_objects = []
    self.order_type.sales_processes.each do |sales_process|
      steps << sales_process.step if sales_process.activated
    end
    steps.each do |step|
      unless step.parent_id.nil?
        step_objects << step.name.camelize.constantize.find_by_order_id(self.id)
      else
        step_name = step.name + "_order"
        step_objects << step_name.camelize.constantize.find_by_order_id(self.id)
      end
    end
    step_objects
  end

  # Return all steps of the order
  def steps
    order_type.sales_processes.collect { |sp| sp.step if sp.activated }
  end
  
  ## Return current step order
  def step
    models = []
    step = nil
    self.commercial_orders.each {|model| models << model}
    #TODO models must content models sorted by position
    models.each {|model| step =  model.step if model.status == "in_progress"}
    if step.nil? 
      models.each {|model| return model.step if model.status == "unstarted"}
    end
    return step
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