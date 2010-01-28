require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'
require File.dirname(__FILE__) + '/new_stock_flow'

class ConsumableCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  include NewStockFlow
  
  def setup
    @supply = Consumable.new
  
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid to perform the next tests" unless @um.save  
  
    @supply_category = ConsumableCategory.new({:name => "root"})
    @supply_category_with_parent = ConsumableCategory.new({:name => "child", :parent => @supply_category, :unit_measure_id => @um.id })
    
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save
    flunk "@supply_category_with_parent should be valid to perform the next tests" unless @supply_category_with_parent.save
  end

  def test_has_many_supplies
    create_consumables
    assert_equal supply_categories(:child_consumable).supplies, [@pvc,@vis], "This ConsumableCategory should have these supplies"
  end
  
  def test_has_many_enabled_and_disabled_supplies
    create_supplier_supplies
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@pvc,@pvc.suppliers.first,true,5)
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@pvc,@pvc.suppliers.first,false,5)
    flunk "@pvc should be disabled with success to perform this test" unless @pvc.disable
    
    assert_equal supply_categories(:child_consumable).enabled_supplies, [@vis], "This ConsumableCategory should have these enabled supplies"
    assert_equal supply_categories(:child_consumable).disabled_supplies, [@pvc], "This ConsumableCategory should have these disabled supplies"
  end
  
  def test_has_many_enabled_and_disabled_categories
    @another_supply_category = ConsumableCategory.new({:name => "second_child", :parent => @supply_category, :unit_measure_id => @um.id })
    flunk "@another_supply_category should be valid to perform the next tests" unless @another_supply_category.save
    flunk "@another_supply_category should be disabled with success to perform this test" unless @another_supply_category.disable
    
    assert_equal @supply_category.enabled_categories, [@supply_category_with_parent], "This ConsumableCategory should have these enabled categories"
    assert_equal @supply_category.disabled_categories, [@another_supply_category], "This ConsumableCategory should have these disabled categories"  
  end
end
