require 'test_helper'

class CityTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'City.count' do
      city = City.create
      assert_not_nil city.errors.on(:name), "A City should have a name"
    end
  end
  
  def test_presence_of_zip_code
    assert_no_difference 'City.count' do
      city = City.create
      assert_not_nil city.errors.on(:zip_code), "A City should have a zip code"
    end
  end
  
  def test_presence_of_country_id
    assert_no_difference 'City.count' do
      city = City.create
      assert_not_nil city.errors.on(:country_id), "A City should have a country id"
    end
  end
end
