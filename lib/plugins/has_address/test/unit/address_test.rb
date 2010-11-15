require File.dirname(__FILE__) + '/../has_address_test'

class AddressTest < ActiveSupport::TestCase
  should_journalize :attributes        => [ :street_name, :city_name, :country_name, :zip_code ],
                    :identifier_method => :formatted

  def test_presence_of_street_name
    assert_no_difference 'Address.count' do
      address = Address.create
      assert_not_nil address.errors.on(:street_name), "An Address should have a street_name"
    end
  end

  def test_presence_of_country_name
    assert_no_difference 'Address.count' do
      address = Address.create
      assert_not_nil address.errors.on(:country_name), "An Address should have a country name"
    end
  end

  def test_presence_of_city_name
    assert_no_difference 'Address.count' do
      address = Address.create
      assert_not_nil address.errors.on(:city_name), "An Address should have a city name"
    end
  end

  def test_presence_of_zip_code
    assert_no_difference 'Address.count' do
      address = Address.create
      assert_not_nil address.errors.on(:zip_code), "An Address should have a zip code"
    end
  end

  def test_numericality_of_zip_code
    assert_no_difference 'Address.count' do
      address = Address.create(:zip_code => 'a')
      assert_not_nil address.errors.on(:zip_code), "An Address should have a zip code"
    end
  end
end
