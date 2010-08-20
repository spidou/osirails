require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTest < ActiveSupport::TestCase
  should_belong_to :customer, :establishment_type, :activity_sector_reference
  
  should_validate_presence_of :name, :address
  should_validate_presence_of :establishment_type, :with_foreign_key => :default
  
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
  
  context "An establishment" do
    setup do
      @establishment = create_establishment_for(Customer.first)
    end
    
    subject{ @establishment }
    
    should_validate_uniqueness_of :siret_number
      
    should "have errors_on_attributes_except_on_contacts? with at least one invalid attribute other that contacts" do
      @establishment.name = nil
      flunk "establishemnt should be invalid " if @establishment.valid?
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
