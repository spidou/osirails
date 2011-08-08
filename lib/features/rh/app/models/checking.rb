class Checking < ActiveRecord::Base
  belongs_to :employee
  
  has_permissions :as_business_object
  
  ABSENCE_MORNING   = "morning"
  ABSENCE_AFTERNOON = "afternoon"
  ABSENCE_WHOLE_DAY = "whole_day"
  ABSENCE_NIL       = nil
  ABSENCE_PERIODS   = [ABSENCE_NIL,ABSENCE_MORNING,ABSENCE_AFTERNOON,ABSENCE_WHOLE_DAY]
  
  before_validation :morning_absence_clean_morning_fields, :afternoon_absence_clean_afternoon_fields, :whole_day_absence_clean_all_fields, :unless => :absence_is_nil?
  
  validates_presence_of :date, :employee_id
  
  validates_uniqueness_of :date, :scope => :employee_id
  
  validates_exclusion_of :absence_period, :in => [ABSENCE_MORNING, ABSENCE_WHOLE_DAY],  :if => Proc.new{ |a| a.is_morning_leave? || !a.scheduled_works_morning? }
  validates_exclusion_of :absence_period, :in => [ABSENCE_AFTERNOON, ABSENCE_WHOLE_DAY],:if => Proc.new{ |a| a.is_afternoon_leave? || !a.scheduled_works_afternoon? }
  
  validates_inclusion_of :absence_period, :in => ABSENCE_PERIODS
  
  validates_presence_of :morning_start,   :if => Proc.new{ |a| !a.scheduled_works_morning? && a.morning_end }
  validates_presence_of :morning_end,     :if => Proc.new{ |a| !a.scheduled_works_morning? && a.morning_start }
  validates_presence_of :afternoon_start, :if => Proc.new{ |a| !a.scheduled_works_afternoon? && a.afternoon_end }
  validates_presence_of :afternoon_end,   :if => Proc.new{ |a| !a.scheduled_works_afternoon? && a.afternoon_start }
  
  validates_presence_of :morning_start_comment,   :if => :morning_start_modification?
  validates_presence_of :morning_end_comment,     :if => :morning_end_modification? 
  validates_presence_of :afternoon_end_comment,   :if => :afternoon_end_modification?
  validates_presence_of :afternoon_start_comment, :if => :afternoon_start_modification?
  validates_presence_of :absence_comment,         :if => :absence_period
  
  validates_inclusion_of :morning_start_comment,   :in => [nil], :unless => :morning_start_modification?
  validates_inclusion_of :morning_end_comment,     :in => [nil], :unless => :morning_end_modification? 
  validates_inclusion_of :afternoon_end_comment,   :in => [nil], :unless => :afternoon_end_modification?
  validates_inclusion_of :afternoon_start_comment, :in => [nil], :unless => :afternoon_start_modification?
  
  validates_date :date, :on_or_before => Date.today
  
  validates_date :morning_start,   :equal_to => :date, :if => :morning_start
  validates_date :morning_end,     :equal_to => :date, :if => :morning_end
  validates_date :afternoon_start, :equal_to => :date, :if => :afternoon_end
  validates_date :afternoon_end,   :equal_to => :date, :if => :afternoon_end
  
  validates_time :morning_start,   :on_or_before => Time.now, :if => Proc.new{ |a| a.morning_start_modification? && (a.date == Date.today)} #OPTIMIZE not sure if "a.date == Date.today" is really useful (validates_time with :on_or_before already check if a.date is equal to Date.today)
  validates_time :morning_end ,    :on_or_before => Time.now, :if => Proc.new{ |a| a.morning_end_modification? && (a.date == Date.today)}
  validates_time :afternoon_start, :on_or_before => Time.now, :if => Proc.new{ |a| a.afternoon_start_modification? && (a.date == Date.today)}
  validates_time :afternoon_end,   :on_or_before => Time.now, :if => Proc.new{ |a| a.afternoon_end_modification? && (a.date == Date.today)}
  
  validates_time :morning_end,     :after =>       :morning_start,   :if => Proc.new{ |a| a.morning_end && a.morning_start }
  validates_time :afternoon_start, :on_or_after => :morning_end,     :if => Proc.new{ |a| a.morning_end && a.afternoon_start }
  validates_time :afternoon_end,   :after =>       :afternoon_start, :if => Proc.new{ |a| a.afternoon_end && a.afternoon_start }
  
  validate :validates_morning_leave
  validate :validates_afternoon_leave
  validate :validates_whole_day_leave
  validate :validates_morning_absence
  validate :validates_afternoon_absence
  validate :validates_whole_day_absence
  validate :validates_checking_is_filled, :unless => :is_whole_day_leave?
  
  # validations
  
  def validates_morning_leave
    if is_morning_leave? && morning_is_not_nil?
      errors.add(:morning_start, errors.generate_message(:morning_start, :leave_morning)) if morning_start_modification? && !is_whole_day_leave?
      errors.add(:morning_end, errors.generate_message(:morning_end, :leave_morning)) if morning_end_modification? && !is_whole_day_leave?
    end
  end
  
  def validates_afternoon_leave
    if is_afternoon_leave? && afternoon_is_not_nil?
      errors.add(:afternoon_start, errors.generate_message(:afternoon_start, :leave_afternoon)) if afternoon_start_modification? && !is_whole_day_leave?
      errors.add(:afternoon_end, errors.generate_message(:afternoon_end, :leave_afternoon)) if afternoon_end_modification? && !is_whole_day_leave?
    end
  end
  
  def validates_whole_day_leave
    if is_whole_day_leave?
      errors.add_to_base(errors.generate_message(:base, :leave_whole_day))
    end
  end
  
  def validates_morning_absence
    if absence_is_morning? && morning_is_not_nil?
      errors.add(:morning_start, errors.generate_message(:morning_start, :absence_morning)) if morning_start_modification? && !absence_is_whole_day?
      errors.add(:morning_end, errors.generate_message(:morning_end, :absence_morning)) if morning_end_modification? && !absence_is_whole_day?
    end
  end
  
  def validates_afternoon_absence
    if absence_is_afternoon? && afternoon_is_not_nil?
      errors.add(:afternoon_start, errors.generate_message(:afternoon_start, :absence_afternoon)) if afternoon_start_modification? && !absence_is_whole_day?
      errors.add(:afternoon_end, errors.generate_message(:afternoon_end, :absence_afternoon)) if afternoon_end_modification? && !absence_is_whole_day?
    end
  end
  
  def validates_whole_day_absence
    if absence_is_whole_day? && ( morning_is_not_nil? || afternoon_is_not_nil? )
      errors.add_to_base(errors.generate_message(:base, :absence_whole_day))
    end
  end
  
  def validates_checking_is_filled
    if absence_is_nil? && self[:morning_start].nil? && self[:morning_end].nil? && self[:afternoon_start].nil? && self[:afternoon_end].nil?
      errors.add_to_base(errors.generate_message(:base, :unfilled_checking))
    end
  end
  
  # getters
  
  def morning_start
    self[:morning_start] || scheduled_morning_start_to_datetime
  end
  
  def morning_end
    self[:morning_end] || scheduled_morning_end_to_datetime
  end
  
  def afternoon_start
    self[:afternoon_start] || scheduled_afternoon_start_to_datetime
  end
  
  def afternoon_end
    self[:afternoon_end] || scheduled_afternoon_end_to_datetime
  end
  
  def morning_start_hours
    datetime_to_float_hours(morning_start)
  end
  
  def morning_end_hours
    datetime_to_float_hours(morning_end)
  end
  
  def afternoon_start_hours
    datetime_to_float_hours(afternoon_start)
  end
  
  def afternoon_end_hours
    datetime_to_float_hours(afternoon_end)
  end
  
  # setters
  
  def morning_start_hours=(hours)
    self[:morning_start] = (hours.to_f == scheduled_morning_start) || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end     
  
  def morning_end_hours=(hours)
    self[:morning_end] = (hours.to_f == scheduled_morning_end) || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end
  
  def afternoon_start_hours=(hours)
    self[:afternoon_start] = (hours.to_f == scheduled_afternoon_start) || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end
  
  def afternoon_end_hours=(hours)
    self[:afternoon_end] = (hours.to_f == scheduled_afternoon_end) || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end
  
  def morning_start_comment=(comment)
    self[:morning_start_comment] = comment.blank? ? nil : comment
  end
  
  def morning_end_comment=(comment)
    self[:morning_end_comment] = comment.blank? ? nil : comment
  end
  
  def afternoon_start_comment=(comment)
    self[:afternoon_start_comment] = comment.blank? ? nil : comment
  end
  
  def afternoon_end_comment=(comment)
    self[:afternoon_end_comment] = comment.blank? ? nil : comment
  end
  
  def absence_period=(absence)
    self[:absence_period] = absence.blank? ? nil : absence
  end
  
  # converters
  
  def scheduled_morning_start_to_datetime
    float_hours_to_datetime(scheduled_morning_start)
  end
  
  def scheduled_morning_end_to_datetime
    float_hours_to_datetime(scheduled_morning_end)
  end
  
  def scheduled_afternoon_start_to_datetime
    float_hours_to_datetime(scheduled_afternoon_start)
  end
  
  def scheduled_afternoon_end_to_datetime
    float_hours_to_datetime(scheduled_afternoon_end)
  end
  
  # return a float by extracting hours and minutes from the given +datetime+
  # 
  # === Exemples :
  # c = Checking.new
  # c.datetime_to_float_hours(DateTime.parse("2011-01-01 09:30:00")) # => 9.5
  #
  def datetime_to_float_hours(datetime) #OPTIMIZE this method should be private, but it's used in 'checkings_helper'
    minutes = (datetime.min/0.6)/100
    datetime.hour + minutes
  end
  
  # schedules
  
  def week_day
    if date
      week_day = ["dimanche","lundi","mardi","mercredi","jeudi","vendredi","samedi"]
      return week_day[date.wday]
    end
  end
  # def wday
  #   date && date.wday
  # end
  
  def schedule_hours
    @schedule_hours ||= Schedule.first(:conditions => ['day=? AND service_id=?', week_day, employee.service_id])
  end
  # def schedule_hours
  #   @schedule = employee.schedule.find(:first, :conditions => ['date = ? AND service_id = ? ' , date,employee.service_id],:order 'date DESC')
  #   @schedule.schedule_hours.find(:first,:conditions => ['day = ?',wday])
  # end
  
  def scheduled_morning_start
    schedule_hours && schedule_hours.morning_start
  end
  
  def scheduled_morning_end
    schedule_hours && schedule_hours.morning_end
  end
  
  def scheduled_afternoon_start
    schedule_hours && schedule_hours.afternoon_start
  end
  
  def scheduled_afternoon_end
    schedule_hours && schedule_hours.afternoon_end
  end
  
  def scheduled_morning_hours
    schedule_hours && schedule_hours.scheduled_morning_hours
  end
  
  def scheduled_afternoon_hours
   schedule_hours &&  schedule_hours.scheduled_afternoon_hours
  end
  
  def scheduled_whole_day_hours
    schedule_hours && schedule_hours.scheduled_total_hours
  end
  
  def scheduled_works_morning?
    schedule_hours && schedule_hours.works_morning?
  end
  
  def scheduled_works_afternoon?
    schedule_hours && schedule_hours.works_afternoon?
  end
  
  def scheduled_works_whole_day?
    schedule_hours && schedule_hours.works_whole_day?
  end
  
  def scheduled_works_today?
    schedule_hours && schedule_hours.works_today?
  end
  
  # leaves
  
  def leaves
    @leaves ||= Leave.all(:conditions => ['start_date <= ? AND end_date >= ? AND employee_id = ?', date, date, employee_id], :order => 'start_date ASC')
  end
  
  def is_morning_leave?
    leaves.each do |leave|
      return true if date != leave.start_date
      return true if date == leave.start_date && !leave.start_half
    end
    return false
  end
  
  def is_afternoon_leave?
    leaves.each do |leave|
      return true if date != leave.end_date
      return true if date == leave.end_date && !leave.end_half
    end
    return false
  end
  
  def is_whole_day_leave?
    is_morning_leave? && is_afternoon_leave?
  end
  
  def is_leave_today?
    is_whole_day_leave? || is_morning_leave? || is_afternoon_leave?
  end
  
  # absence
  
  def absence_is_morning?
    absence_period == ABSENCE_MORNING
  end
  
  def absence_is_afternoon?
    absence_period == ABSENCE_AFTERNOON
  end
  
  def absence_is_whole_day?
    absence_period == ABSENCE_WHOLE_DAY
  end
  
  def absence_is_nil?
      absence_period == ABSENCE_NIL
  end
  
  def is_absence_today?
    absence_is_whole_day? || absence_is_morning? || absence_is_afternoon?
  end
  
  def morning_absence_clean_morning_fields
    if absence_is_morning?
      clean_morning_fields
    end
  end
  
  def afternoon_absence_clean_afternoon_fields
    if absence_is_afternoon?
      clean_afternoon_fields
    end
  end
  
  def whole_day_absence_clean_all_fields
    if absence_is_whole_day?
      clean_morning_fields
      clean_afternoon_fields
    end
  end
  
  
  def morning_start_modification?
    !self[:morning_start].nil?
  end
  
  def morning_end_modification?
    !self[:morning_end].nil?
  end
  
  def afternoon_start_modification?
    !self[:afternoon_start].nil?
  end
  
  def afternoon_end_modification?
    !self[:afternoon_end].nil?
  end
  
  # overtime
  
  def morning_start_is_overtime?
    if morning_start_modification? && scheduled_works_morning?
       scheduled_morning_start_to_datetime > float_hours_to_datetime(morning_start_hours)
    else
      false
    end
  end
  
  def morning_end_is_overtime?
    if morning_end_modification? && scheduled_works_morning?
      scheduled_morning_end_to_datetime < float_hours_to_datetime(morning_end_hours)
    else
      false
    end
  end
  
  def afternoon_start_is_overtime?
    if afternoon_start_modification? && scheduled_works_afternoon?
      scheduled_afternoon_start_to_datetime >  float_hours_to_datetime(afternoon_start_hours)
    else
      false
    end
  end
  
  def afternoon_end_is_overtime?
    if afternoon_end_modification? && scheduled_works_afternoon?
      scheduled_afternoon_end_to_datetime < float_hours_to_datetime(afternoon_end_hours)
    else
      false
    end
  end
  
  # delay
  
  def morning_start_delay?
    if morning_start_modification? && scheduled_works_morning?
      scheduled_morning_start_to_datetime < float_hours_to_datetime(morning_start_hours)
    else
      false
    end
  end
  
  def morning_end_delay?
    if morning_end_modification? && scheduled_works_morning?
      scheduled_morning_end_to_datetime >  float_hours_to_datetime(morning_end_hours)
    else
      false
    end
  end
  
  def afternoon_start_delay?
    if afternoon_start_modification? && scheduled_works_afternoon?
      scheduled_afternoon_start_to_datetime < float_hours_to_datetime(afternoon_start_hours)
    else
      false
    end
  end
  
  def afternoon_end_delay?
    if afternoon_end_modification? && scheduled_works_afternoon?
      scheduled_afternoon_end_to_datetime > float_hours_to_datetime(afternoon_end_hours)
    else
      false
    end
  end
  
  
  def working_morning_start_hours
    if morning_start_modification? && scheduled_morning_start
      worked_hours = morning_start_hours - scheduled_morning_start
      worked_hours < 0 ? worked_hours * -1 : worked_hours
    end
  end
  
  def working_morning_end_hours
    if morning_end_modification? && scheduled_morning_end
      worked_hours = morning_end_hours - scheduled_morning_end
      worked_hours < 0 ? worked_hours * -1 : worked_hours
    end
  end
  
  def working_afternoon_start_hours
    if afternoon_start_modification? && scheduled_afternoon_start
      worked_hours = afternoon_start_hours - scheduled_afternoon_start
      worked_hours < 0 ? worked_hours * -1 : worked_hours
    end
  end
  
  def working_afternoon_end_hours
    if afternoon_end_modification? && scheduled_afternoon_end
      worked_hours = afternoon_end_hours - scheduled_afternoon_end
      worked_hours < 0 ? worked_hours * -1 : worked_hours
    end
  end
  
  def working_morning_hours
    worked_morning? ? morning_end_hours - morning_start_hours : 0
  end
  
  def working_afternoon_hours
    worked_afternoon? ? afternoon_end_hours - afternoon_start_hours : 0
  end
  
  def working_whole_day_hours
    working_morning_hours + working_afternoon_hours
  end
  
  
  def worked_morning?
    morning_start && morning_end  && !absence_is_morning? && !absence_is_whole_day? && !is_morning_leave? && !is_whole_day_leave?
  end
  
  def worked_afternoon?
    afternoon_start && afternoon_end && !absence_is_afternoon? && !absence_is_whole_day? && !is_afternoon_leave? && !is_whole_day_leave?
  end
  
  def worked_whole_day?
    worked_morning? && worked_afternoon?
  end
  
  def worked_today?
    worked_morning? || worked_afternoon?
  end
  
  
  def scheduled_total_hours
    if is_whole_day_leave?
      0
    elsif is_morning_leave?
      scheduled_afternoon_hours
    elsif is_afternoon_leave?
      scheduled_morning_hours
    else
      scheduled_whole_day_hours
    end
  end
  
  def balance_worked_hours
    if schedule_hours
      working_whole_day_hours - scheduled_total_hours
    end
  end
  
  def morning_is_not_nil?
    !self[:morning_start].nil? || !self[:morning_start_comment].nil? || !self[:morning_end].nil? || !self[:morning_end_comment].nil?
  end
  
  def afternoon_is_not_nil?
    !self[:afternoon_start].nil? || !self[:afternoon_start_comment].nil? || !self[:afternoon_end].nil? || !self[:afternoon_end_comment].nil?
  end
  
  private
    # return a datetime, according to the checking's date and the given +float+
    # 
    # === Exemples :
    # c = Checking.new(:date => "2011-01-01")
    # c.send(:float_hours_to_datetime, 10.5) # => Sat, 01 Jan 2011 10:30:00
    #
    def float_hours_to_datetime(float)
      hours = float.to_i
      minutes = hours > 0 ? float%hours : float
      minutes = (minutes*60).to_i
      #return DateTime.new(date.year, date.month, date.day, hours, minutes, 0, DateTime.now.zone)
      return date + hours.hours + minutes.minutes #TODO test if Timezone is ok
    end
    
    def clean_morning_fields
      self[:morning_start] = nil
      self[:morning_start_comment] = nil
      self[:morning_end] = nil
      self[:morning_end_comment] = nil
    end
    
    def clean_afternoon_fields
      self[:afternoon_start] = nil
      self[:afternoon_start_comment] = nil
      self[:afternoon_end] = nil
      self[:afternoon_end_comment] = nil
    end
end
