require 'test/test_helper'

class UnitMeasureTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'UnitMeasure.count' do
      unit_measure = UnitMeasure.create
      assert_not_nil unit_measure.errors.on(:name), "An UnitMeasure should have a name"
    end
  end

  def test_presence_of_symbol
    assert_no_difference 'UnitMeasure.count' do
      unit_measure = UnitMeasure.create
      assert_not_nil unit_measure.errors.on(:symbol), "An UnitMeasure should have a symbol"
    end
  end
end
