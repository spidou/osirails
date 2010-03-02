class OrderType < ActiveRecord::Base
  has_and_belongs_to_many :society_activity_sectors
  
  has_many :sales_processes
  has_many :orders
  has_many :checklist_options_order_types
  has_many :checklist_options, :through => :checklist_options_order_types

  validates_presence_of :title
  
  def activated?
    activated
  end
  
  ## Create all sales Process after create
  def after_create
    Step.find(:all).each do |step|
      sales_processes.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
    end
  end
  
  ## Return activated step for order_type
  def activated_steps
    sales_processes.select{ |sp| sp.activated? }.collect{ |sp| sp.step }
  end
  
end
