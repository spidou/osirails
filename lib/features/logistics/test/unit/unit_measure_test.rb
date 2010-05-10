require 'test/test_helper'

class UnitMeasureTest < ActiveSupport::TestCase
  
  should_validate_presence_of :name, :symbol
  
  should_validate_uniqueness_of :name, :symbol
  
  context "An unit_measure" do
    setup do
      @unit_measure = UnitMeasure.new(:name => "Milimeter", :symbol => "mm")
    end
    
    should "have a valid 'symbol_and_name'" do
      assert_equal "mm (milimeter)", @unit_measure.symbol_and_name
    end
  end
  
end
