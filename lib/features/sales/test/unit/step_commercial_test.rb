require 'test_helper'

class StepCommercialTest < ActiveSupport::TestCase
  def test_presence_of_order_id
    assert_not_nil 'StepCommercial.count' do
      step_commercial = StepCommercial.create
      assert_not_nil step_commercial.errors.on(:order_id),
        "A StepCommercial should have an order id"
    end
  end
end
