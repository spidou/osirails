class Order < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :establishment
  belongs_to :commercial, :class_name => 'Employee'
  has_one :step_commercial
  has_one :step_invoicing
  has_many :order_logs

  # Validations
  validates_presence_of [:order_type, :establishment, :customer, :commercial]
  
  
  # Create all orders_steps after create
  def after_create
    ## Creation of steps
    order_type.activated_steps.each do |step|
      if step.parent.nil?
        step.name.camelize.constantize.create(:order_id => self.id, :status => 'unstarted')
      else
        s = step.name.camelize.constantize.create(step.parent.name + '_id' => self.send(step.parent.name).id, :status => 'unstarted')
        step.checklists.each do |checklist|
          checklist_response = ChecklistResponse.create :checklist_id => checklist.id
          s.checklist_responses << checklist_response  
        end
      end
    end    
  end

  def step
    self.all_childrens.each do |child|
      next if child.step.parent.nil?
      return child.step if (child.in_progress? || child.unstarted?)
    end
    return nil
  end

  # Return all steps of the order
  def steps
    order_type.sales_processes.collect { |sp| sp.step if sp.activated }
  end

  # Return a has for advance statistics
  def advance
    steps_obj = []
    advance = {}
    steps.each do |step|
      next if step.parent
      steps_obj += send(step.name).childrens
    end
    advance[:total] = steps_obj.size
    advance[:terminated] = 0
    steps_obj.each { |s| advance[:terminated] += 1 if s.terminated? }
    advance
  end
  
  def childrens
    childs = []
    steps.each do |step|
      next if step.parent
      childs << send(step.name)
    end
    childs
  end
  
  def all_childrens
    all_childs = []
    childrens.each do |child|
      all_childs << child
      all_childs += child.childrens
    end
    all_childs
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
  
  def terminated?
    return false unless closed_date?
    childrens.each do |child|
      return false unless child.terminated?
    end
    true
  end
end