require File.dirname(__FILE__) + '/../sales_test'

class SubcontractorTest < ActiveSupport::TestCase
  
  #TODO has_permissions :as_business_object
  
  should_have_one :iban
  
  should_belong_to :activity_sector_reference
  
  should_validate_presence_of :activity_sector_reference, :with_foreign_key => :default
  
  journalize :attributes        => [ :name, :legal_form_id, :company_created_at, :collaboration_started_at, :activated ],
             :subresources      => [ :contacts, :address, :phone, :fax, :iban ],
             :identifier_method => :name
  
  context "A subcontractor" do
    setup do
      @siret_number_owner = Subcontractor.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
  
  context "Thanks to 'has_contacts', a subcontractor" do
    setup do
      @contacts_owner = Subcontractor.new
    end
    
    include HasContactsTest
  end
  
end
