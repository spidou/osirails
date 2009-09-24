require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'

class ConsumableCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  
  def setup
    @supply = Consumable.new
  
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid to perform the next tests" unless @um.save  
  
    @supply_category = ConsumableCategory.new({:name => "root"})
    @supply_category_with_parent = ConsumableCategory.new({:name => "child", :consumable_category => @supply_category, :unit_measure_id => @um.id })
    
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save
    flunk "@supply_category_with_parent should be valid to perform the next tests" unless @supply_category_with_parent.save
  end

  def test_has_many_consumables
    create_consumables
    assert_equal consumable_categories(:child).consumables, [@pvc,@vis], "This ConsumableCategory should have these consumables"
  end
end
