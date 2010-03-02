require 'test/test_helper'

class SalesProcessTest < ActiveSupport::TestCase
  def test_presence_of_order_type_id
    assert_no_difference 'SalesProcess.count' do
      sales_process = SalesProcess.create
      assert_not_nil sales_process.errors.on(:order_type_id),
        "A SalesProcess should have an order type id"
    end
  end

  def test_presence_of_step_id
    assert_no_difference 'SalesProcess.count' do
      sales_process = SalesProcess.create
      assert_not_nil sales_process.errors.on(:step_id),
        "A SalesProcess should have a step id"
    end
  end
end
