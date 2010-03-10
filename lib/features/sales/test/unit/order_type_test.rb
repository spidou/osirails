require 'test/test_helper'

class OrderTypeTest < ActiveSupport::TestCase
  def test_presence_of_title
    assert_no_difference 'OrderType.count' do
      order_type = OrderType.create
      assert_not_nil order_type.errors.on(:title), "An OrderType should have a title"
    end
  end

  def test_sales_process
    order_type = OrderType.create(:title => 'test')
    assert_equal Step.count,
      SalesProcess.find_all_by_order_type_id(order_type.id).size,
      "An OrderType should create sales process after create"
  end
end
