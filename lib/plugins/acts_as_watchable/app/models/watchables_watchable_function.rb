class WatchablesWatchableFunction < ActiveRecord::Base
  
  belongs_to :watchable
  belongs_to :watchable_function
  
  validates_presence_of :watchable_id, :watchable_function_id
  validates_presence_of :time_unity , :if => :on_schedule
  
  validate :validates_on_modification_and_on_schedule
  
  attr_accessor :should_destroy
  attr_accessor :on_modification_tmp
  attr_accessor :on_schedule_tmp
  
  MINUTLY_UNITY = "minutly"
  HOURLY_UNITY = "hourly"
  DAILY_UNITY = "daily"
  WEEKLY_UNITY = "weekly"
  MOUNTHLY_UNITY = "mounthly"
  YEARLY_UNITY = "yearly"
  
  def validates_on_modification_and_on_schedule
    return if self.should_destroy?
    
    if (self.watchable_function && self.on_modification && !self.watchable_function.on_modification)
      errors.add(:on_modification, "ne doit pas etre cocher")
    end
    
    if (self.watchable_function && self.on_schedule && !self.watchable_function.on_schedule)
      errors.add(:on_schedule, "ne doit pas etre cocher")
    end
  end
     
  def should_destroy?
    self.should_destroy ? true : false
  end
  
  def selected?
    (self.on_modification || self.on_schedule)
  end
   
end
