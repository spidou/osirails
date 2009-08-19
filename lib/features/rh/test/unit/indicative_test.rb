require 'test/test_helper'

class IndicativeTest < ActiveSupport::TestCase
  fixtures :indicatives

  def setup
    @indicative = indicatives(:reunion)
  end

  def test_presence_of_indicative
    assert_no_difference 'Indicative.count' do
      indicative = Indicative.create
      assert_not_nil indicative.errors.on(:indicative), "An Indicative should have an indicative"
    end
  end

  def test_presence_of_country_id
    assert_no_difference 'Indicative.count' do
      indicative = Indicative.create
      assert_not_nil indicative.errors.on(:country_id), "An Indicative should have a country id"
    end
  end
end
