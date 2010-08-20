require File.dirname(__FILE__) + '/../sales_test'

class SalesProcessTest < ActiveSupport::TestCase
  should_belong_to :order_type, :step
  should_validate_presence_of :order_type, :step, :with_foreign_key => :default
end
