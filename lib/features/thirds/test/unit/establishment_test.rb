require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTest < ActiveSupport::TestCase
  should_belong_to :customer, :establishment_type, :activity_sector_reference
  
  should_validate_presence_of :address
  
  should_journalize :attributes        => [ :name, :establishment_type_id, :activity_sector_reference_id, :siret_number, :activated, :hidden ],
                    :subresources      => [ :address, :contacts, :documents, :phone, :fax ],
                    :attachments       => :logo,
                    :identifier_method => :establishment_type_and_name
  
  context "A new establishment" do
    setup do
      @establishment = Establishment.new
    end
    
    teardown do
      @establishment = nil
    end
    
    should "not be able to be hidden" do
      assert !@establishment.can_be_hidden?
    end
    
    should "not hide" do
      @establishment.hide
      assert !@establishment.hidden_was
    end
  end
  
  # test errors_on_attributes_except_on_contacts?
  context "A valid establishment" do
    setup do
      @establishment = create_establishment_for(Customer.first)
      flunk "@establishment should be valid" unless @establishment.valid?
    end
    
    subject{ @establishment }
    
    should_validate_uniqueness_of :siret_number
    
    [:address, :establishment_type_id, :establishment_type].each do |attr|
      should "have errors_on_attributes_except_on_contacts? when its '#{attr}' is invalid" do
        @establishment.send("#{attr}=", nil)
        flunk "establishemnt should be invalid" if @establishment.valid?
        assert @establishment.errors_on_attributes_except_on_contacts?
      end
    end
    
    should "have errors_on_attributes_except_on_contacts? when its 'siret_number' is invalid" do
      @establishment.siret_number = "invalid siret number"
      flunk "establishemnt should be invalid" if @establishment.valid?
      assert @establishment.errors_on_attributes_except_on_contacts?
    end
    
    should "not have errors_on_attributes_except_on_contacts? with errors only on contacts" do
      @establishment.contacts.build
      flunk "contact should be invalid" if @establishment.contacts.first.valid?
      assert !@establishment.errors_on_attributes_except_on_contacts?
    end
    
    should "not have errors_on_attributes_except_on_contacts? without any invalid attributes" do 
      assert !@establishment.errors_on_attributes_except_on_contacts?
    end
    
    should "be able to be hidden" do
      assert @establishment.can_be_hidden?
    end
    
    should "hide" do
      @establishment.hide
      assert @establishment.hidden_was
    end
  end
  
  context "Thanks to 'has_contacts', an establishment" do
    setup do
      @contacts_owner = Establishment.new
    end
    
    include HasContactsTest
  end
  
  context "An establishment" do
    setup do
      @siret_number_owner = Establishment.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
end
