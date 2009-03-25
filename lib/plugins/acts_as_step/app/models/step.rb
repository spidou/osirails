class Step < ActiveRecord::Base
  # Relationships
  belongs_to :parent, :class_name =>'Step', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Step', :foreign_key => 'parent_id'
  has_and_belongs_to_many :sales_processes
  has_and_belongs_to_many :dependencies, :class_name => "Step", :join_table => 'step_dependencies', :foreign_key => 'step_id', :association_foreign_key => 'step_dependent'
  
  has_many :checklists
  
  # Plugins
  acts_as_list :scope => :parent_id
  acts_as_tree :order => :position
  
  ## Return a tree which represent step architecture
#  def self.tree
#    parents = []
#    get_children(Step.find_all_by_parent_id(:order => "position"), parents)  
#  end
#  
#  def self.cant_find(step_name = '')
#    raise "can't find step #{step_name}"
#  end
  
  def path
    name[5..-1].downcase
  end
  
  # Return his parent or himself
  def first_parent
    self.parent.nil? ? self : self.parent
  end
  
#  ## Return all orders which are in current step
#  def orders
#    orders = []
#    OrdersSteps.find_all_by_status(self.name).each {|order_step| orders << Order.find(order_step.order_id)}
#    orders
#  end
#  
#  ## Return all orders which have finish current step
#  def terminated_orders
#    orders = []
#    OrdersSteps.find_all_by_step_id_and_status(self.id, "terminated").each{|order_step| orders << order_step.order}
#    orders
#  end
#  
#  ## Return all orders which haven't start current step
#  #FIXME FInd the good word to say 'unstarted'
#  def unstarted_orders
#    orders = []
#    OrdersSteps.find_all_by_step_id_and_status(self.id, "unstarted").each{|order_step| orders << order_step.order}
#    orders
#  end
  
  ## Acts_as_list method
  def insert_at(position)  
    super(position_in_bounds(position))
  end
  
  protected
    # This method permit to return a valide position for a step.
    def position_in_bounds(position)
      if position < 1 
        1
      elsif position > self.self_and_siblings.size
        self.self_and_siblings.size
      else
        position
      end
    end
    
  private
    # This method insert in the parents the menus   
    def self.get_children(steps, parents)
      steps.each do |step|
        parents << step
        # If the menu has children, the get_children method is call.
        if step.children.size > 0
          get_children(step.children, parents)
        end
      end
      parents
    end
end
