class OrderType < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :society_activity_sectors
  has_many :sales_processes
  has_many :orders
  
  ## Create all sales Process after create
  def after_create
    Step.find(:all).each do |step|
      SalesProcess.create(:order_type_id => self.id, :step_id => step.id)
    end
  end
  
  ## Return activated step for order_type
  def activated_steps
    self.sales_processes.collect {|sp| sp.step if sp.activated }
  end
end