require File.dirname(__FILE__) + '/../thirds_test'

class CustomerGradeTest < ActiveSupport::TestCase
  should_belong_to :payment_time_limit
end
