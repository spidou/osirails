require File.dirname(__FILE__) + '/../sales_test'

class OrderFormTypeTest < ActiveSupport::TestCase
  should_journalize :identifier_method => :name
end
