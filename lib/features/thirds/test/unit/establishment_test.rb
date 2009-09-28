require 'test/test_helper'

class EstablishmentTest < ActiveSupport::TestCase
  fixtures :establishments

  def setup
    @establishment = establishments(:first_establishment)
  end

  def test_presence_of_name
    assert_no_difference 'Establishment.count' do
      establishment = Establishment.create
      assert_not_nil establishment.errors.on(:name),
        "An Establishment should have a name"
    end
  end

  def test_presence_of_address
    assert_no_difference 'Establishment.count' do
      establishment = Establishment.create
      assert_not_nil establishment.errors.on(:address),
        "An Establishment should have an address"
    end
  end

  def test_save_address
    @establishment.build_address(:street_name => "1 rue des rosiers",
                                 :country_name => "Réunion",
                                 :city_name => "Saint-Denis",
                                 :zip_code => "97400")
    @establishment.save!
    assert @establishment.reload.address, "This Establishment should have an address"
  end
end
