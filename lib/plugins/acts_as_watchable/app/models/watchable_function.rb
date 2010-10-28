class WatchableFunction < ActiveRecord::Base
  has_many :watchings_watchable_functions
  has_many :watchings, :through => :watchings_watchable_functions
  
  named_scope :on_modifications,  :conditions => ["watchable_functions.on_modification = ?", true]
  named_scope :on_schedules,      :conditions => ["watchable_functions.on_schedule = ?", true]
  
  validates_presence_of :watchable_type, :name, :description
  
  validates_presence_of :on_modification, :unless => :on_schedule
  validates_presence_of :on_schedule,     :unless => :on_modification
  
  validates_uniqueness_of :name, :scope => :watchable_type
  
  def can_execute_class_method?
    watchable_type.constantize.respond_to?(name)
  end
  
  def execute_class_method
    watchable_type.constantize.send(name) if can_execute_class_method?
  end
  
end
