class WatchableFunction < ActiveRecord::Base
  
  has_many :watchables_watchable_functions
  has_many :watchables, :through => :watchables_watchable_functions
  
  validates_presence_of :function_type, :function_name, :function_description
  validates_presence_of :on_modification, :unless => :on_schedule
  validates_presence_of :on_schedule, :unless => :on_modification
  
  def can_execute_class_method?
    self.function_type.constantize.respond_to?(self.function_name)
  end
  
  def execute_class_method
    self.function_type.constantize.send(self.function_name) if self.can_execute_class_method?
  end
  
end
