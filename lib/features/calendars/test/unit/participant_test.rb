require File.dirname(__FILE__) + '/../calendars_test'

class ParticipantTest < ActiveSupport::TestCase
  def test_presence_of_event_id
    assert_no_difference 'Participant.count' do
      participant = Participant.create
      assert_not_nil participant.errors.on(:event_id),
        "A Participant should have an event id"
    end
  end

  def test_belongs_to_event
    assert_equal participants(:normal).event, events(:normal),
      "This Participant should belongs to this Event"
  end
end
