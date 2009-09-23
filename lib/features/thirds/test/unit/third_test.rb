require 'test/test_helper'

class ThirdTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'Third.count' do
      third = Third.create
      assert_not_nil third.errors.on(:name), "A Third should have a name"
    end
  end

  def test_presence_of_legal_form
    assert_no_difference 'Third.count' do
      third = Third.create
      assert_not_nil third.errors.on(:legal_form), "A Third should have a legal form"
    end
  end

  def test_presence_of_siret_number
    assert_no_difference 'Third.count' do
      third = Third.create
      assert_not_nil third.errors.on(:siret_number), "A Third should have a siret number"
    end
  end

  def test_presence_of_activity_sector
    assert_no_difference 'Third.count' do
      third = Third.create
      assert_not_nil third.errors.on(:activity_sector), "A Third should have a activity sector"
    end
  end

  def test_format_of_siret_number
    assert_no_difference 'Third.count' do
      third = Third.create(:siret_number => 1)
      assert_not_nil third.errors.on(:siret_number), "A Third should have a siret number with a good format"
    end
  end
end
