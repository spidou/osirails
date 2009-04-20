require 'test_helper'

class EstablishmentTest < ActiveSupport::TestCase
  def setup
    @establishement = Establishment.create(:name => "Mon Etablissement")
  end

  def test_presence_of_name
    assert_no_difference 'Establishment.count' do
      establishement = Establishment.create
      assert_not_nil establishement.errors.on(:name),
        "An Establishment should have a name"
    end
  end

  def test_presence_of_address
    assert_no_difference 'Establishment.count' do
      establishement = Establishment.create
      assert_not_nil establishement.errors.on(:address),
        "An Establishment should have an address"
    end
  end

  def test_save_address
    address = Address.new(:address1 => "1 rue des rosiers",
                          :address2 => "",
                          :country_name => "Réunion",
                          :city_name => "Saint-Denis",
                          :zip_code => "97400")
    @establishement.update_attributes(:address => address)
    assert Establishment.find_by_name(@establishement.name).address,
      "This Establishment should have an address"
  end
end
