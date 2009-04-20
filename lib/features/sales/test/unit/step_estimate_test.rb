require 'test_helper'

class StepEstimateTest < ActiveSupport::TestCase
  def test_presence_of_order_id
    assert_not_nil 'StepEstimate.count' do
      step_estimate = StepEstimate.create
      assert_not_nil step_estimate.errors.on(:order_id),
        "A StepEstimate should have an order id"
    end
  end
end
