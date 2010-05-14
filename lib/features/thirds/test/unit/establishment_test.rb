require 'test/test_helper'
require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTest < ActiveSupport::TestCase
  should_belong_to :customer, :establishment_type, :activity_sector_reference
  
  should_validate_presence_of :name, :address
  should_validate_presence_of :establishment_type, :with_foreign_key => :default
  
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
  
  context "An establishment" do
    setup do
      @siret_number_owner = Establishment.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
end
