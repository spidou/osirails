class OrderType < ActiveRecord::Base
  has_many :sales_processes
  #has_many :steps, :through => :sales_processes #TODO test if this assocation is good
  
  # TODO replace the method 'activated_steps' by theses two associations
  #has_many :activated_sales_processes, :class_name => 'SalesProcess', :conditions => [ "activated = ?", true ]
  #has_many :activated_steps, :through => :activated_sales_processes, :source => :step
  
  has_many :orders
  has_many :checklist_options_order_types
  has_many :checklist_options, :through => :checklist_options_order_types

  validates_presence_of :title
  
  has_search_index :only_attributes => [ :id, :title ],
                   :identifier      => :title
  
  after_create :create_sales_processes
  after_save :clean_caches
  
  ## Return activated step for order_type, and select only steps which are constantizable (so which are actually in LOAD_PATH)
  def activated_steps
    sales_processes.ordered.select{ |sp| sp.activated? }.collect{ |sp| sp.step }.select{ |step| step.name.camelize.constantize rescue false }
  end
  
  private
    def create_sales_processes
      Step.find(:all, :order => 'parent_id, position').each do |step|
        sales_processes.ordered.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
      end
    end
    
    def clean_caches
      orders.each do |o|
        o.send(:clean_caches)
      end
    end
end
