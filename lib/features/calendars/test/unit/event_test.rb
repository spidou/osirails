require 'test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :events, :calendars, :alarms, :participants, :exception_dates

  def setup
    @event = events(:normal)
  end

  def test_presence_of_title
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:title), "An Event should have a title"
    end
  end

  def test_presence_of_start_at
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:start_at), "An Event should have a start at date"
    end
  end

  def test_presence_of_end_at
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:end_at), "An Event should have a end at date"
    end
  end

  def test_belongs_to_calendar
    assert_equal @event.calendar, calendars(:normal),
      "This Event should belongs to this Calendar"
  end

  def test_custom_daily_frequence
    assert events(:every_two_days).is_custom_daily_frequence?,
      "This Event should have a custom daily frequence"
  end

  def test_custom_weekly_frequence
    assert events(:every_two_weeks).is_custom_weekly_frequence?,
      "This Event should have a custom weekly frequence"
    assert events(:every_monday).is_custom_weekly_frequence?,
      "This Event should have a custom weekly frequence"
  end

  def test_custom_monthly_frequence
    # TODO Do more test with this method
    assert events(:every_two_months).is_custom_monthly_frequence?,
      "This Event should have a custom monthly frequence"
  end

  def test_custom_yearly_frequence
    assert events(:every_two_years).is_custom_yearly_frequence?,
      "This Event should have a custom yearly frequence"
  end

  def test_create_alarm
    assert_difference 'Alarm.count', +1, "This Event should create an Alarm after create" do
      event = Event.create(:title => 'Foo',
                           :start_at => Time.now - 1.hour,
                           :end_at => Time.now)
    end
  end

  def test_has_many_alarms
    assert_equal @event.alarms, [alarms(:normal)],
      "This Event should have this Alarm"
  end

  def test_has_many_participants
    assert_equal @event.participants, [participants(:normal)],
      "This Event should have this Participant"
  end

  def test_has_many_exception_dates
    assert_equal @event.exception_dates, [exception_dates(:normal)],
      "This Event should have this ExceptionDate"
  end
end
