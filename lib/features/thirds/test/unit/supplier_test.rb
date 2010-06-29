require File.dirname(__FILE__) + '/../thirds_test'

class SupplierTest < ActiveSupport::TestCase
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
  
  context "A supplier" do
    setup do
      @siret_number_owner = Supplier.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
end
