require File.dirname(__FILE__) + '/../sales_test'

class OrderTypeTest < ActiveSupport::TestCase
  should_have_many :sales_processes, :orders, :checklist_options_order_types
  should_have_many :checklist_options, :through => :checklist_options_order_types

  should_validate_presence_of :title
  
  def test_sales_process
    order_type = OrderType.create(:title => 'test')
    assert_equal Step.count,
      SalesProcess.find_all_by_order_type_id(order_type.id).size,
      "An OrderType should create sales process after create"
  end
end
