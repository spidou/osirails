require File.dirname(__FILE__) + '/../calendars_test'

class AlarmTest < ActiveSupport::TestCase
  def setup
    @alarm = Alarm.new
    @alarm.valid?
  end
  
  def teardown
    @alarm = nil
  end
  
  def test_presence_of_event
    assert @alarm.errors.invalid?(:event), "event should NOT be valid because it's nil"
    
    @alarm.event = events(:normal)
    @alarm.valid?
    assert !@alarm.errors.invalid?(:event), "event should be valid"
  end

  def test_belongs_to_event
    assert_equal alarms(:normal).event, events(:normal),
      "This Alarm should belongs to this Event"
  end
  
  def test_presence_of_description
    assert @alarm.errors.invalid?(:description), "description should NOT be valid because it's nil"
    
    @alarm.description = 'a comment'
    @alarm.valid?
    assert !@alarm.errors.invalid?(:description), "description should be valid"
  end
  
  def test_presence_of_email_to
    assert @alarm.errors.invalid?(:email_to), "email_to should NOT be valid because it's nil"
    
    @alarm.email_to = 'good.email@home.com'
    @alarm.valid?
    assert !@alarm.errors.invalid?(:email_to), "email_to should be valid"
  end
  
  def test_numericality_of_do_alarm_before
    assert @alarm.errors.invalid?(:do_alarm_before), "do_alarm_before should NOT be valid because it's nil"
    
    @alarm.do_alarm_before = "string"
    @alarm.valid?
    assert @alarm.errors.invalid?(:do_alarm_before), "do_alarm_before should NOT be valid because it's not a numerical value"
    
    @alarm.do_alarm_before = 12
    @alarm.valid?
    assert !@alarm.errors.invalid?(:do_alarm_before), "do_alarm_before should be valid"
  end
  
  def test_numericality_of_duration
    assert !@alarm.errors.invalid?(:duration), "duration should be valid because nil is allowed"
    
    @alarm.duration = "string"
    @alarm.valid?
    assert @alarm.errors.invalid?(:duration), "duration should NOT be valid because it's not a numerical value"
    
    @alarm.duration = 12
    @alarm.valid?
    assert !@alarm.errors.invalid?(:duration), "duration should be valid"
  end
  
  def test_format_of_email_to # /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/
    @alarm.email_to = 'bad@email@home..com'
    @alarm.valid?
    assert @alarm.errors.invalid?(:email_to), "email_to should not be valid because it don't match the regexp"
    
    @alarm.email_to = 'good.email@home.com'
    @alarm.valid?
    assert !@alarm.errors.invalid?(:email_to), "email_to should be valid"
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
