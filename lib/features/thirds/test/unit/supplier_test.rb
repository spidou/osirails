require 'test/test_helper'

class SupplierTest < ActiveSupport::TestCase
  fixtures :thirds, :ibans

  def setup
    @supplier = Supplier.first
  end

  def test_uniqness_of_name
    assert_no_difference 'Supplier.count' do
      supplier = Supplier.create(:name => @supplier.name)
      assert_not_nil supplier.errors.on(:name),
        "A Supplier should have an uniq name"
    end
  end

  def test_uniqness_of_siret_number
    assert_no_difference 'Supplier.count' do
      supplier = Supplier.create(:siret_number => @supplier.siret_number)
      assert_not_nil supplier.errors.on(:siret_number),
        "A Supplier should have an uniq siret number"
    end
  end

  def test_save_iban
    assert_difference 'Iban.count', +1 do
      @supplier.iban = Iban.new(ibans(:normal_iban).attributes)
      @supplier.save
      assert_not_nil @supplier.iban, "This Supplier should have an Iban"
    end
  end
end
