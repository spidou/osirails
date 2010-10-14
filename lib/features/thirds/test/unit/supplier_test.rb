require File.dirname(__FILE__) + '/../thirds_test'

class SupplierTest < ActiveSupport::TestCase
  #TODO has_permissions :as_business_object
  
  should_have_one :iban
  
  should_belong_to :activity_sector_reference
  
  should_validate_presence_of :activity_sector_reference, :with_foreign_key => :default
  
  should_validate_uniqueness_of :name
  should_validate_uniqueness_of :siret_number, :scoped_to => :type
  
  context "Thanks to 'has_contacts', a supplier" do
    setup do
      @contacts_owner = Supplier.new
    end
    
    include HasContactsTest
  end
  
  context "A supplier" do
    setup do
      @siret_number_owner = Supplier.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
  
  context "A new supplier a name defined" do
    setup do
      @supplier = Supplier.new(:name => "Supplier name")
    end
    
    subject{@supplier}
    
    should_have_one :iban
    should_validate_uniqueness_of :siret_number, :scoped_to => :type
    
    context 'with required attributes and a built iban then saved' do
      setup do
        @supplier = create_supplier(@supplier)
      end
      
      should 'have saved the iban too' do
        assert_not_nil @supplier.iban.id
      end
    end
  end
end
