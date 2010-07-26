require File.dirname(__FILE__) + '/../rh_test'

class PremiumTest < ActiveSupport::TestCase
  def setup
    @premium = premia(:john_doe_premium)
  end

  def test_belongs_to_employee
    assert_equal employees(:john_doe), @premium.employee,
      "This Premium should belongs to this Employee"
  end

  def test_validates_format_of_amount
    assert_no_difference 'Premium.count' do
      premium = Premium.create(:amount => 'a')
      assert_not_nil premium.errors.on(:amount),
        "A Premium should have a numeric value as amount"
    end
  end
end
