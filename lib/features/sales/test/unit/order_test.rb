require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    # TODO Do more unit test for Order
  end

  def test_presence_of_title
    assert_no_difference 'Order.count' do
      order = Order.create
      assert_not_nil order.errors.on(:title), "An Order should have a title"
    end
  end

  def test_presence_of_customer_id
    assert_no_difference 'Order.count' do
      order = Order.create
      assert_not_nil order.errors.on(:customer_id), "An Order should have a customer id"
    end
  end

  def test_presence_of_commercial_id
    assert_no_difference 'Order.count' do
      order = Order.create
      assert_not_nil order.errors.on(:commercial_id), "An Order should have a commercial id"
    end
  end

  def test_presence_of_establishment_id
    assert_no_difference 'Order.count' do
      order = Order.create
      assert_not_nil order.errors.on(:establishment_id), "An Order should have an establishement id"
    end
  end

  def test_presence_of_order_type_id
    assert_no_difference 'Order.count' do
      order = Order.create
      assert_not_nil order.errors.on(:order_type_id), "An Order should have an order type id"
    end
  end
end
