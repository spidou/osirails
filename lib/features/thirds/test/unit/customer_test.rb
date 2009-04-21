require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  fixtures :thirds

  def setup
    @customer = thirds(:customer_normal)
  end

  # FIXME This test does not work
  #def test_uniqness_of_name
  #  assert_no_difference 'Customer.count' do
  #    customer = Customer.create(:name => @customer.name)
  #    assert_not_nil customer.errors.on(:name), "A Customer should have an uniq name"
  #  end
  #end

  # FIXME This test does not work
  #def test_uniqness_of_siret_number
  #  assert_no_difference 'Customer.count' do
  #    customer = Customer.create(:siret_number => @customer.siret_number)
  #    assert_not_nil customer.errors.on(:siret_number),
  #      "A Customer should have an uniq siret number"
  #  end
  #end
end
