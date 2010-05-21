class Alarm < ActiveRecord::Base
  # The structure of the Event is based on the RFC 2445. It permit to make
  # iCalendar format.
  # Convert method are based on the Icalendar plugins made by Jeff Rose.
  #
  # Describing:
  #
  # :action             "DISPLAY" || "EMAIL"
  # :description        :text
  # :do_alarm_before    :integer
  # :repeat             :integer
  # :duration           :integer
  # :email_to           :string
  #
  # If you choose the "DISPLAY" action, you must specifies: action,
  # description, and trigger.
  # If you choose the "EMAIL" action, you must specifies: action, description,
  # trigger, and summary.
  #
  # Examples:
  #
  # {:action => "DISPLAY", :duration => 15.minutes, :repeat => 2,
  # :do_alarm_before => 30.minutes}
  # The Alarm specifies a display alarm that will trigger 30 minutes before 
  # the scheduled start of the event or the due date/time of the to-do it is
  # associated with and will repeat 2 more times at 15 minute intervals.
  
  DELAY_UNIT = ['minute','hour','day','week']
  
  # Relationships
  belongs_to :event

  # Validations
  validates_presence_of :event, :description, :email_to
  validates_numericality_of :do_alarm_before
  validates_numericality_of :duration,    :allow_nil => true
  validates_format_of :email_to,          :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/
  
  attr_accessor :should_destroy
  
  # Requires
  require 'rubygems'
  require 'icalendar'
  require 'date'
  
  # Convert the alarm to the an Icalendar alarm object
  def to_ical_alarm
    alarm = Icalendar::Alarm.new
    alarm.action        = action if action
    alarm.description   = description if description
    alarm.trigger       = Calendar.to_ical_seconds(do_alarm_before) if do_alarm_before
    alarm.repeat        = repeat if repeat
    alarm.duration      = to_ical_seconds(duration) if duration
    alarm.summary       = repeat if repeat
    alarm.add_attendee("MAILTO:" + email_to) if email_to
    alarm
  end
  
  def should_destroy?
    should_destroy.to_i == 1  
  end
  
  # method that return the delay (do_before_alarm) in the best human readable unit
  # ==== examples
  # #=> 720 secondes -> 12 minutes
  # #=> 2 minutes    -> 2 minutes
  # #=> 7 days       -> 1 week
  #
  # return a hash like : {:unit => 'minute', :value => 12} for 'do_alarm_before == 720' for example
  #
  def humanize_delay
    units  = Alarm::DELAY_UNIT
    ratios = [60,60,24,7]
    value  = do_alarm_before.to_f
    result = 0
    
    (0..3).each do |i|
      value /= ratios[i]
      result = {:unit => units[i], :value => value.to_i} if value.floor == value.ceil and value.floor >= 1
    end
    result
  end
end
