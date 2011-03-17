require File.dirname(__FILE__) + '/../thirds_test'

class GrantedPaymentTimeTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
end
