class Event < ActiveRecord::Base
  # The structure of the Event is based on the RFC 2445. It permit to make
  # iCalendar format.
  # Convert method are based on the Icalendar plugins made by Jeff Rose.
  #
  # Describing:
  #
  # title         Title of the Event
  # color         Hexa color (optional)
  # status        "TENTATIVE" || "CONFIRMED" || "CANCELLED"
  # location      :text
  # description   :text
  # start_at      :date || :datetime
  # end_at        :date || :datetime
  # organizer_id  :user
  # until_date    :date
  # frequence     "DAILY" || "WEEKLY" || "MONTHLY" || "YEARLY"
  # count         :integer || :string
  # interval      :integer
  # by_day        (:integer) && ["SU" || "MO" || "TU" || "WE" || "TH" || "FR"
  #               || "SA"]
  # by_month_day  [:integer]
  # by_month      [:integer || :string]
  #
  # Use:
  # You must specified an interval (default 1) with a frequence.
  #
  # Examples:
  #
  # {:frequence => "DAILY", :count => 10, :interval => 2}
  # This recurrence specifies 10 meetings every 2 days.
  #
  # {:frequence => "MONTHLY", :count => 3, :by_day => [TU,WE,TH],
  # :by_set_pos => 3}
  # The 3rd instance into the month of one of Tuesday, Wednesday or Thursday,
  # for the next 3 months.
  #
  # {:frequence => "YEARLY", :interval => 2, :by_month => 1 :by_day => ["SU"],
  # :by_hour => "8,9", :by_minute => 30}
  # First, the ":interval => 2" would be applied to ":frequence => "YEARLY"" 
  # to arrive at "every other year". Then, ":by_month => 1" would be applied
  # to arrive at "every January, every other year". Then, ":by_day => "SU""
  # would be applied to arrive at "every Sunday in January, every other year".
  # Then, "BYHOUR=8,9" would be applied to arrive at "every Sunday in January
  # at 8 AM and 9 AM, every other year". Then, ":by_minute => 30" would be
  # applied to arrive at "every Sunday in January at 8:30 AM and 9:30 AM,
  # every other year".
  
  # Callbacks
#  after_create :create_alarm
  after_update :save_alarms
  before_save :clear_empty_attrs
  before_save :create_event_category_from_name
  
  # Accessor
  attr_accessor :new_event_category_name
  
  # Validates
  validates_presence_of :title, :start_at, :end_at
  validates_associated :alarms
  
  # Relationships
  belongs_to :calendar
  has_many :alarms
  has_many :participants
  has_many :exception_dates

  # Serializations
  serialize :by_day
  serialize :by_month_day
  serialize :by_month
  
  # Requires
  require 'rubygems'
  require 'icalendar'
  require 'date'
  
  def is_custom_daily_frequence?
    self.frequence == "DAILY" && self.interval > 1
  end
  
  def is_custom_weekly_frequence?
    self.frequence == "WEEKLY" && (!self.by_day.nil? || self.interval > 1)
  end
  
  def is_custom_monthly_frequence?
    self.frequence == "MONTHLY" && (!self.by_month_day.nil? || !self.by_day.nil? || self.interval > 1)
  end
  
  def is_custom_yearly_frequence?
    self.frequence == "YEARLY" && (!self.by_month.nil? || !self.by_day.nil? || self.interval > 1)
  end
  
  def is_custom_frequence?
    is_custom_daily_frequence? || is_custom_weekly_frequence? || is_custom_monthly_frequence? || is_custom_yearly_frequence?
  end
  
  # Convert the event to the an Icalendar event object
  def to_ical_event
    organizer = User.find(organizer_id) if organizer_id
    
    event = Icalendar::Event.new
    event.summary               = title.to_s if title
    event.location              = location.to_s if location
    event.description           = description.to_s if description
    event.status                = status if status
    event.properties["rrule"]   = "FREQ=" + frequence if frequence
    event.properties["rrule"]   += ";UNTIL=" + Calendar.to_ical_date(until_date) if until_date
    event.properties["rrule"]   += ";COUNT=" + count.to_s if count
    event.properties["rrule"]   += ";INTERVAL=" + interval.to_s if interval
    event.properties["rrule"]   += ";BYDAY=" + by_day.join(',') if by_day
    event.properties["rrule"]   += ";BYMONTHDAY=" + by_month_day.to_s if by_month_day
    event.properties["rrule"]   += ";BYMONTH=" + by_month.to_s if by_month_day
    event.properties["rrule"]   += ";WKST=MO" if by_day.grep(/\d/).empty?
    event.properties["rrule"].gsub!(" ", "")
    event.organizer("MAILTO:" + organizer[:mail], {"cn" => (organizer.employee.fullname || organizer.username)}) if organizer
    event.dtstart(Calendar.to_ical_date(start_at), Calendar.param_tz) if start_at
    event.dtend(Calendar.to_ical_date(end_at), Calendar.param_tz) if end_at
    
    exception_dates.each do |e|
      event.add_exception_date(Calendar.to_ical_date(e.date))
    end
    
    participants.each do |p|
      event.add_attendee("MAILTO=" + p.email, {"cn" => p.name})
    end
    
    alarms.each do |a|
      event.alarms += [a.to_ical_alarm]
    end
    
    event
  end
  
#  # this method permit to save the alarms of the event when it is passed with the event form
#  def alarm_attributes=(alarm_attributes)
#    alarm_attributes.each do |attributes|
#      if attributes[:id].blank?
#        self.alarms.build(attributes)
#      else
#        alarm = self.alarms.detect {|t| t.id == attributes[:id].to_i} 
#        alarm.attributes = attributes
#      end
#    end
#  end
  
  protected
    def clear_empty_attrs
      @attributes.each do |key,value|
        self[key] = nil if value.blank? unless key == "full_day"
      end
    end

    def create_event_category_from_name
      unless new_event_category_name.blank?
        if EventCategory.find_all_accessible(self.calendar).collect { |ec| ec.name}.include?(new_event_category_name)
          self.event_category_id = EventCategory.find_by_name(new_event_category_name).id
        else
          category = EventCategory.create(:name => new_event_category_name)
          self.calendar.event_categories << category
          self.event_category_id = category.id
        end
      end
    end

    def save_alarms
      alarms.each do |alarm|
        if alarm.should_destroy?    
          alarm.destroy    
        else
          alarm.save(false)
        end
      end
    end
#    def create_alarm
#      self.alarms << Alarm.create(:title => "Alarme")
#    end
end
