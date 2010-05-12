require 'test/test_helper'
require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTest < Test::Unit::TestCase
  should_belong_to :customer, :establishment_type, :activity_sector_reference
  
  should_validate_presence_of :name, :address, :siret_number
  should_validate_presence_of :establishment_type, :with_foreign_key => :default
  
  should_allow_values_for :siret_number, "12345678901234", "09876543210987"
  should_not_allow_values_for :siret_number, "azert", "azertyuiopqsdf", "1234567890123", "123456789012345", "1234567890123a", "", nil
  
  context "An establishment" do
    setup do
      @establishment = create_establishment_for(Customer.first)
    end
    
    subject{ @establishment }
    
    should_validate_uniqueness_of :siret_number
  end
  
  context "Thanks to 'has_contacts', an establishment" do
    setup do
      @contacts_owner = create_establishment_for(Customer.first)
    end
    
    include HasContactsTest
  end
end
