require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTest < ActiveSupport::TestCase
  should_belong_to :customer, :establishment_type, :activity_sector_reference
  
  should_validate_presence_of :name, :address
  should_validate_presence_of :establishment_type, :with_foreign_key => :default
  
  #TODO uncomment this line and find why we have the following error when running test : "Can't find first Establishment"
  #should_validate_uniqueness_of :siret_number
  
  context "A valid establishment" do
    setup do
      @establishment = Establishment.new(:name                  => "Name",
                                         :establishment_type_id => establishment_types(:store).id,
                                         :siret_number          => "35478965321567")
      @establishment.build_address(:street_name   => "Street Name",
                                   :zip_code      => "12345",
                                   :city_name     => "City",
                                   :country_name  => "Country")
      
      flunk "@establishment should be valid" unless @establishment.valid?
    end
    
    should "be saved successfully" do
      assert @establishment.save!
    end
  end

#  # TODO test save address in has_address plugin
#  def test_save_address
#    @establishment.build_address(:street_name   => "1 rue des rosiers",
#                                 :country_name  => "Réunion",
#                                 :city_name     => "Saint-Denis",
#                                 :zip_code      => "97400")
#    @establishment.save!
#    assert @establishment.reload.address, "This Establishment should have an address"
#  end
  
  context "An establishment" do
    setup do
      @siret_number_owner = Establishment.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
end
