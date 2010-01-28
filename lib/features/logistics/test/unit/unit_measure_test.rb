require 'test/test_helper'

class UnitMeasureTest < ActiveSupport::TestCase
  def setup
    @um = UnitMeasure.new
    @um.valid?
  end
  
  def test_presence_of_name
    assert @um.errors.on(:name), "@um should NOT be valid because name is nil"
    
    @um.name = "millimètre"
    @um.valid?
    assert !@um.errors.on(:name), "@um should be valid"
  end

  def test_presence_of_symbol
    assert @um.errors.on(:symbol), "@um should NOT be valid because symbol is nil"
    
    @um.symbol = "mm"
    @um.valid?
    assert !@um.errors.on(:symbol), "@um should be valid"
  end
end
