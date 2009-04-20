require 'test_helper'

class StepInvoicingTest < ActiveSupport::TestCase
  def test_presence_of_order_id
    assert_no_difference 'StepInvoicing.count' do
      step_invoicing = StepInvoicing.create
      assert_not_nil step_invoicing.errors.on(:order_id),
        "A StepInvoicing should have an order id"
    end
  end
end
