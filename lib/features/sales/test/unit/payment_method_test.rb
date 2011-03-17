require File.dirname(__FILE__) + '/../sales_test'

class PaymentMethodTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
  
  should_journalize :identifier_method => :name
end
