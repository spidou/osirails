require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  def test_presence_of_event_id
    assert_no_difference 'Participant.count' do
      participant = Participant.create
      assert_not_nil participant.errors.on(:event_id),
        "A Participant should have an event id"
    end
  end
end
