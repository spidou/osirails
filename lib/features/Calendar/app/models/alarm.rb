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
  # :repeat             :integer
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
  
  # Relationships
  belongs_to :event
  
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
end
