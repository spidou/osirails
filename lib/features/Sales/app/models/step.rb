class Step < ActiveRecord::Base
  # Relationships
  belongs_to :parent_step, :class_name =>"Step", :foreign_key => "parent_id"
  has_and_belongs_to_many :sales_processes
  has_and_belongs_to_many :orders
  has_many :checklists
  
  #FIXME See if it's not better to replace parent_name by parent_id 
  ## Return all orders which are in current step
  def self.orders
    orders = []
    OrdersSteps.find(:all, :conditions => ["status = ?", self.name]).each {|order_step| orders << Order.find(order_step.order_id)}
    orders
  end
  
  ## Return all orders which have finish current step
  def self.finished_orders
    
  end
  
  ## Return all orders which haven't start current step
  #FIXME FInd the good word to say 'unstarted'
  def unstarted_orders
    
  end
  
  ## Return children's step
  def self.childrens
    Step.find(:all, :conditions => ["parent_id = ?", self.id])
  end
  
  ## Return parent's step
  def self.parent
    Step.find_by_parent_id(self.parent_id)
  end
end