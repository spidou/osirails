require 'test/test_helper'
require File.dirname(__FILE__) + '/../logistics_test'

class SupplyCategoriesSupplySizeTest < ActiveSupport::TestCase
  should_belong_to :supply_sub_category, :supply_size, :unit_measure
  
  should_validate_presence_of :supply_size, :with_foreign_key => :default
  
  context "A supply_categories_supply_size without unit_measure" do
    setup do
      @supply_categories_supply_size = SupplyCategoriesSupplySize.new
    end
    
    should "be marked for destroy" do
      assert @supply_categories_supply_size.should_destroy?
    end
  end
  
  context "A supply_categories_supply_size with unit_measure" do
    setup do
      @supply_categories_supply_size = SupplyCategoriesSupplySize.new(:unit_measure_id => UnitMeasure.first.id)
    end
    
    should "NOT be marked for destroy" do
      assert !@supply_categories_supply_size.should_destroy?
    end
  end
end
