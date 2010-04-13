require 'test/test_helper'

class CustomerGradeTest < Test::Unit::TestCase
  should_belong_to :payment_time_limit
end
