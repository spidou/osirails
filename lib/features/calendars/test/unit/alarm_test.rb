require 'test/test_helper'

class AlarmTest < ActiveSupport::TestCase
  fixtures :alarms, :events

  def test_presence_of_event_id
    assert_no_difference 'Alarm.count' do
      alarm = Alarm.create
      assert_not_nil alarm.errors.on(:event_id), "An Alarm should have an event id"
    end
  end

  def test_belongs_to_event
    assert_equal alarms(:normal).event, events(:normal),
      "This Alarm should belongs to this Event"
  end
  
  def test_humanize_delay
    alarm = alarms(:normal)
    
    # do alarm_before is into secondes but the given args are intergers minutes converted into secondes
    alarm.do_alarm_before = 12*60 # 720s
    assert_equal alarm.humanize_delay[:value], 12, "with 720s value should be 12"
    assert_equal alarm.humanize_delay[:unit], 'minute', "with 720 unit should be 'minute'"
    
    alarm.do_alarm_before = 60*60 # 1h
    assert_equal alarm.humanize_delay[:value], 1, "with 3600s value should be 1"
    assert_equal alarm.humanize_delay[:unit], 'hour', "with 720 unit should be 'hour'"
    
    alarm.do_alarm_before = 1.5*60*60 # 1h30min
    assert_equal alarm.humanize_delay[:value], 1, "with #{1.5*60*60}s value should be 90"
    assert_equal alarm.humanize_delay[:unit], 'minute', "with 720 unit should be 'minute'"
    
    alarm.do_alarm_before = 2*60*60*24 # 2j
    assert_equal alarm.humanize_delay[:value], 2, "with #{2*60*60*24}s value should be 2"
    assert_equal alarm.humanize_delay[:unit], 'day', "with 720 unit should be 'day'"
    
    alarm.do_alarm_before = 7*60*60*24 # 7j
    assert_equal alarm.humanize_delay[:value], 1, "with #{7*60*60*24}s value should be 1"
    assert_equal alarm.humanize_delay[:unit], 'week', "with 720 unit should be 'week'"
  end
end
