require 'test_helper'

class SupplierTest < ActiveSupport::TestCase
  fixtures :thirds

  def setup
    @supplier = thirds(:supplier_normal)
  end

  # FIXME This test does not work
  #def test_uniqness_of_name
  #  assert_no_difference 'Supplier.count' do
  #    supplier = Supplier.create(:name => @supplier.name)
  #    assert_not_nil supplier.errors.on(:name),
  #      "A Supplier should have an uniq name"
  #  end
  #end

  # FIXME This test does not work
  #def test_uniqness_of_siret_number
  #  assert_no_difference 'Supplier.count' do
  #    supplier = Supplier.create(:siret_number => @supplier.siret_number)
  #    assert_not_nil supplier.errors.on(:siret_number),
  #      "A Supplier should have an uniq siret number"
  #  end
  #end

  def test_save_iban
    # TODO Test this method
  end
end
