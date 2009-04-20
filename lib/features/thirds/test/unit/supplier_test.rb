require 'test_helper'

class SupplierTest < ActiveSupport::TestCase
  def setup
    @supplier = Supplier.create(:name => "Foo",
                                :siret_number => "12345678912345",
                                :activated => true)
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
    assert_difference 'Iban.count', +1, "This supplier should have an Iban" do
      @supplier.update_attributes(:iban => Iban.new(:bank_name => "Bred",
                                                     :bank_code => "12345",
                                                     :branch_code => "12345",
                                                     :account_number => "12345678901",
                                                     :key => "12"))
    end
  end
end
