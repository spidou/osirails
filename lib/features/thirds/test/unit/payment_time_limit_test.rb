require 'test/test_helper'

class PaymentTimeLimitTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'PaymentTimeLimit.count' do
      payment_time_limit = PaymentTimeLimit.create
      assert_not_nil payment_time_limit.errors.on(:name),
        "A PaymentTimeLimit should have a name"
    end
  end
end
