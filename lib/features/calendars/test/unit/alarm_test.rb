require 'test_helper'

class AlarmTest < ActiveSupport::TestCase
  def test_presence_of_event_id
    assert_no_difference 'Alarm.count' do
      alarm = Alarm.create
      assert_not_nil alarm.errors.on(:event_id), "An Alarm should have an event id"
    end
  end
end
