require 'test/test_helper'

require File.dirname(__FILE__) + '/unit/customer_base_test'
require File.dirname(__FILE__) + '/unit/supplier_base_test'
require File.dirname(__FILE__) + '/unit/siret_number_test'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
  
  def get_customer(factorised = true) # TODO set 'factorised' at false by default, and make relative changements in whole project
    if factorised == true
      customer = thirds(:factorised_customer)
    else
      customer = thirds(:first_customer)
    end
    
    head_office = build_head_office_for(customer)
    
    if customer.establishments.empty?
      establishment = create_establishment_for(customer)
      establishment.contacts.build(:first_name  => "Pierre Paul",
                                   :last_name   => "Jacques",
                                   :job         => "Commercial",
                                   :email       => "pierre_paul@jacques.com",
                                   :gender      => "M")
      establishment.contacts.build(:first_name  => "Jean",
                                   :last_name   => "Dupond",
                                   :job         => "Comptable",
                                   :email       => "jean@dupond.com",
                                   :gender      => "M")
    end
    
    customer.build_bill_to_address( :street_name  => "Street Name",
                                    :country_name => "Country",
                                    :city_name    => "City",
                                    :zip_code     => "01234" ) unless customer.bill_to_address
    customer.save!
    flunk "customer should have at least 2 contacts\nbut has #{customer.contacts.count}" unless customer.contacts.count >= 2
    return customer
  end
  
  def build_establishment_for(customer)
    siret = rand(99999999999999).to_s.rjust(14, "0")
    establishment = customer.establishments.build(:name                   => "Customer Establishment",
                                                  :establishment_type_id  => establishment_types(:store).id,
                                                  :siret_number           => siret,
                                                  :activated              => true)
    establishment.build_address( :street_name  => "Street Name",
                                 :country_name => "Country",
                                 :city_name    => "City",
                                 :zip_code     => "01234" )
    return establishment
  end
  
  def create_establishment_for(customer)
    establishment = build_establishment_for(customer)
    establishment.save!
    return establishment
  end
  
  def build_head_office_for(customer)
    siret = rand(99999999999999).to_s.rjust(14, "0") 
    establishment = customer.build_head_office( :name                   => "Customer Head Office",
                                                :establishment_type_id  => establishment_types(:store).id,
                                                :siret_number           => siret,
                                                :activated              => true)
    establishment.build_address( :street_name  => "Street Name",
                                 :country_name => "Country",
                                 :city_name    => "City",
                                 :zip_code     => "01234" )
    return establishment
  end
  
  def create_address(city_name = "Paris")
    address = Address.new(:street_name => "1 rue de #{city_name}",
                          :country_name => "France",
                          :city_name => city_name,
                          :zip_code => (city_name == "Paris" ? "75001" : "12345"),
                          :has_address_type => "Type",
                          :has_address_key => "Key")
    address.save!
    address
  end
  
  def create_custom_activity_sector
    custom_activity_sector = CustomActivitySector.new(:name => "Custom Activtity")
    custom_activity_sector.save!
    custom_activity_sector
  end
  
  def create_activity_sector
    activity_sector = ActivitySector.new(:name => "Activity Sector")
    activity_sector.save!
    activity_sector
  end
  
  def create_activity_sector_reference(activity_sector, custom_activity_sector, code = "11.11Z")
    activity_sector_reference = ActivitySectorReference.new(:code => code,
                                                            :activity_sector_id => activity_sector.id,
                                                            :custom_activity_sector_id => custom_activity_sector.id)
    activity_sector_reference.save!
    activity_sector_reference
  end
  
  def create_third_type(name = "Third Type")
    third_type = ThirdType.new( :name => name)
    third_type.save!
    third_type
  end
  
  def create_legal_form(name = "LLC (Limited Liability Company)", third_type = create_third_type )
    legal_form = LegalForm.new( :name => name,
                                :third_type_id => third_type.id)
    legal_form.save!
    legal_form
  end
  
  def initialize_datatase_for_supplier
    @custom_activity_sector = create_custom_activity_sector
    @activity_sector = create_activity_sector
    @activity_sector_reference = create_activity_sector_reference(@activity_sector, @custom_activity_sector)
    @third_type = create_third_type
    @legal_form = create_legal_form
  end
  
  def create_supplier(supplier = Supplier.new)
    initialize_datatase_for_supplier
    
    supplier.name ||= "Supplier Name"
    supplier.activity_sector_reference_id = @activity_sector_reference.id
    supplier.legal_form_id = @legal_form.id
  
    supplier.iban_attributes=({:bank_name      => "Bank",
                                :bank_code      => "12345",
                                :branch_code    => "12345",
                                :account_number => "12345678901",
                                :key            => "12"})
    flunk 'Failed to build iban' unless supplier.iban
    supplier.save!
    
    supplier
  end
  
  def create_forwarder
    legal_form = create_legal_form
  
    forwarder = Forwarder.new(:name => "Forwarder Name")
    forwarder.legal_form_id = legal_form.id
    forwarder.save!
    forwarder
  end
  
  def create_user
    username ||= "admin_user"
    password ||= Digest::SHA1.hexdigest("password")
    enabled ||= true
    password_updated_at ||= Time.now - 1.hours
    user = User.new(:username => username, :password => password, :enabled => enabled, :password_updated_at => password_updated_at )
    user.save!
    user
  end
end
