require 'test/test_helper'

class PaymentMethodTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'PaymentMethod.count' do
      payment_method = PaymentMethod.create
      assert_not_nil payment_method.errors.on(:name),
        "A PaymentMethod should have a name"
    end
  end
end
