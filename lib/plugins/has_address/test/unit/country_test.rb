require File.dirname(__FILE__) + '/../has_address_test'

class CountryTest < ActiveSupport::TestCase
  def setup
    @country = countries(:france)
  end

  def test_presence_of_name
    assert_no_difference 'Country.count' do
      country = Country.create
      assert_not_nil country.errors.on(:name), "A Country should have a name"
    end
  end

  def test_presence_of_code
    assert_no_difference 'Country.count' do
      country = Country.create
      assert_not_nil country.errors.on(:code), "A Country should have a code"
    end
  end

  def test_uniqness_of_name
    assert_no_difference 'Country.count' do
      country = Country.create(:name => @country.name)
      assert_not_nil country.errors.on(:name), "A Country should have an uniq name"
    end
  end
end
