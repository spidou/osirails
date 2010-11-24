class WatchingsWatchableFunction < ActiveRecord::Base
  MINUTLY_UNITY = "minutly"
  HOURLY_UNITY  = "hourly"
  DAILY_UNITY   = "daily"
  WEEKLY_UNITY  = "weekly"
  MONTHLY_UNITY = "monthly"
  YEARLY_UNITY  = "yearly"
  
  belongs_to :watching
  belongs_to :watchable_function
  
  named_scope :minutlies, :conditions => ["time_unity = ?", MINUTLY_UNITY]
  named_scope :hourlies,  :conditions => ["time_unity = ?", HOURLY_UNITY]
  named_scope :dailies,   :conditions => ["time_unity = ?", DAILY_UNITY]
  named_scope :weeklies,  :conditions => ["time_unity = ?", WEEKLY_UNITY]
  named_scope :monthlies, :conditions => ["time_unity = ?", MONTHLY_UNITY]
  named_scope :yearlies,  :conditions => ["time_unity = ?", YEARLY_UNITY]
  
  validates_presence_of :watchable_function_id
  validates_presence_of :time_unity , :if => :on_schedule
  
  validate :validates_on_modification_and_on_schedule
  
  attr_accessor :should_destroy
  attr_accessor :on_modification_tmp
  attr_accessor :on_schedule_tmp
  
  def should_destroy?
    should_destroy
  end
  
  def validates_on_modification_and_on_schedule
    return if should_destroy?
    
    if selected?
      if on_modification and watchable_function and !watchable_function.on_modification
        errors.add(:on_modification, I18n.t("activerecord.errors.models.watchings_watchable_function.attributes.on_modification.is_not_blank"))
      end
      
      if on_schedule and watchable_function and !watchable_function.on_schedule
        errors.add(:on_schedule, I18n.t("activerecord.errors.models.watchings_watchable_function.attributes.on_schedule.is_not_blank"))
      end
    else
      errors.add(:on_modification, I18n.t("activerecord.errors.models.watchings_watchable_function.attributes.on_modification.is_blank"))
      errors.add(:on_schedule, I18n.t("activerecord.errors.models.watchings_watchable_function.attributes.on_schedule.is_blank"))
    end
  end
  
  def selected?
    on_modification || on_schedule
  end
end
