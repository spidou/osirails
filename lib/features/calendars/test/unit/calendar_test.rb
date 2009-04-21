require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
  fixtures :calendars, :users, :event_categories

  def setup
    @calendar = calendars(:normal)
  end

  def test_belongs_to_user
    assert_equal @calendar.user, users(:powerful_user),
      "This Calendar should belongs to this User"
  end

  def test_has_many_events
    @calendar.events.each do |event|
      assert event.class == Event, "This Calendar should have many Events"
    end
  end

  def test_has_many_event_categories
    assert_equal @calendar.event_categories, [event_categories(:normal)],
      "This Calendar should have this EventCategory"
  end

  def test_events_at_period
    # TODO Test the method events_at_period
  end

  def test_events_at_date
    @calendar.events_at_date(Date.today) do |event|
      assert (event.start_at.to_date <= Date.today) and
        (event.end_at.to_date >= Date.today),
        "This Calendar return wrong Events at the specified date"
    end
  end

  def test_alarms_at_date
    # TODO First code the method in calendar.rb
  end
end
