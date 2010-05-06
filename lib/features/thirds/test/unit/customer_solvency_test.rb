require 'test/test_helper'

class CustomerSolvencyTest < Test::Unit::TestCase
  should_belong_to :payment_method
end
