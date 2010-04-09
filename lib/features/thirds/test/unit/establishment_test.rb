require 'test/test_helper'

class EstablishmentTest < Test::Unit::TestCase
  should_belong_to :customer
  should_belong_to :establishment_type
  
  should_allow_values_for :siret_number, "12345678901234", "09876543210987"
  should_not_allow_values_for :siret_number, "azert", "azertyuiopqsdf", "1234567890123", "123456789012345", "1234567890123a", "", nil
  
  context "An empty establishment" do
    setup do
      @establishment = Establishment.new
      @establishment.valid?
    end
    
    [ :name, :address, :establishment_type, :siret_number].each do |attribute|
      should "require presence of #{attribute}" do
        assert @establishment.errors.invalid?(attribute)
      end
    end
  end
  
  context "A complete establishment" do
    setup do
      @establishment = Establishment.new(:name                  => "Name",
                                         :establishment_type_id => establishment_types(:store).id,
                                         :siret_number => "35478965321567")
      @establishment.build_address(:street_name   => "Street Name",
                                   :zip_code      => "12345",
                                   :city_name     => "City",
                                   :country_name  => "Country")
      @establishment.valid?
    end
    
    [ :name, :address, :establishment_type, :siret_number].each do |attribute|
      should "valid presence of #{attribute}" do
        assert !@establishment.errors.invalid?(attribute)
      end
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
end
