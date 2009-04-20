require 'test_helper'

class StepGraphicConceptionTest < ActiveSupport::TestCase
  def test_presence_of_commercial_id
    assert_no_difference 'StepGraphicConception.count' do
      step_graphic_conception = StepGraphicConception.create
      assert_not_nil step_graphic_conception.errors.on(:commercial_id),
        "A StepGraphicConception should have a commercial id"
    end
  end
end
