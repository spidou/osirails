require File.dirname(__FILE__) + '/../calendars_test'

class ExceptionDateTest < ActiveSupport::TestCase
  def test_presence_of_event_id
    assert_no_difference 'ExceptionDate.count' do
      exception_date = ExceptionDate.create
      assert_not_nil exception_date.errors.on(:event_id),
        "An ExceptionDate should have an event id"
    end
  end

  def test_presence_of_date
    assert_no_difference 'ExceptionDate.count' do
      exception_date = ExceptionDate.create
      assert_not_nil exception_date.errors.on(:date),
        "An ExceptionDate should have a date"
    end
  end

  def test_belongs_to_event
    assert_equal exception_dates(:normal_exception_date).event, events(:two_hours_ago),
      "This ExceptionDate should belongs to this Event"
  end
end
