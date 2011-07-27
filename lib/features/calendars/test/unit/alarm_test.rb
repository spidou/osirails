require File.dirname(__FILE__) + '/../calendars_test'

class AlarmTest < ActiveSupport::TestCase
  should_belong_to :event

  should_validate_presence_of :description, :email_to
  should_validate_numericality_of :do_alarm_before, :duration
  
  should_allow_values_for :email_to, "foo@bar.com"
  should_not_allow_values_for :email_to, "", "something", "foo@", "@bar.com", "foo@bar.", "foo@bar.c", "foo@bar.abcdef"
  
  def setup
    @alarm = Alarm.new
    @alarm.valid?
  end
  
  subject{ @alarm }
  
  def test_humanize_delay
    alarm = alarms(:normal_alarm)
    
    # do alarm_before is into secondes but the given args are intergers minutes converted into secondes
    alarm.do_alarm_before = 12*60 # 720s
    assert_equal alarm.humanize_delay[:value], 12, "with 720s value should be 12"
    assert_equal alarm.humanize_delay[:unit], 'minute', "with 720 unit should be 'minute'"
    
    alarm.do_alarm_before = 60*60 # 1h
    assert_equal alarm.humanize_delay[:value], 1, "with 3600s value should be 1"
    assert_equal alarm.humanize_delay[:unit], 'hour', "with 720 unit should be 'hour'"
    
    alarm.do_alarm_before = 1.5*60*60 # 1h30min
    assert_equal alarm.humanize_delay[:value], 90, "with #{1.5*60*60}s value should be 90"
    assert_equal alarm.humanize_delay[:unit], 'minute', "with 720 unit should be 'minute'"
    
    alarm.do_alarm_before = 2*60*60*24 # 2j
    assert_equal alarm.humanize_delay[:value], 2, "with #{2*60*60*24}s value should be 2"
    assert_equal alarm.humanize_delay[:unit], 'day', "with 720 unit should be 'day'"
    
    alarm.do_alarm_before = 7*60*60*24 # 7j
    assert_equal alarm.humanize_delay[:value], 1, "with #{7*60*60*24}s value should be 1"
    assert_equal alarm.humanize_delay[:unit], 'week', "with 720 unit should be 'week'"
  end
end
