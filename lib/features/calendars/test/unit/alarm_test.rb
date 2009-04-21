require 'test_helper'

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
end
