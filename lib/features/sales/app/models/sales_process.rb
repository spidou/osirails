class SalesProcess < ActiveRecord::Base
  belongs_to :order_type
  belongs_to :step
  
  named_scope :ordered, :include => :step, :order => 'steps.parent_id, steps.position'
  
  validates_presence_of :order_type_id, :step_id
  validates_presence_of :order_type,  :if => :order_type_id
  validates_presence_of :step,        :if => :step_id
end
