require 'test_helper'

class ActivitySectorTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'ActivitySector.count' do
      activity_sector = ActivitySector.create
      assert_not_nil activity_sector.errors.on(:name), "An ActivitySector should have a name"
    end
  end
end
