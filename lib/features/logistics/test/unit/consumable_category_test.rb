require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'

class ConsumableCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  
  def setup
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid to perform the next tests" unless @um.save  
  
    @supply_category = ConsumableCategory.new({:name => "root"})
    @supply_category_with_parent = ConsumableCategory.new({:name => "child", :consumable_category => @supply_category, :unit_measure_id => @um.id })
    
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save
    flunk "@supply_category_with_parent should be valid to perform the next tests" unless @supply_category_with_parent.save
  end

  def test_has_many_consumable_categories
    assert_equal @supply_category.consumable_categories, [@supply_category_with_parent],
      "@supply_category should have a child consumable category"
  end

  def test_has_many_consumables
    create_consumables
    assert_equal consumable_categories(:child).consumables, [@pvc,@vis], "This ConsumableCategory should have these consumables"
  end

  def test_belongs_to_consumable_category
    assert_equal @supply_category_with_parent.consumable_category, @supply_category, "@supply_category_with_parent should have a parent"
  end
  
  def test_stock_value
    @cc = ConsumableCategory.new
    assert_equal 0.0, @cc.stock_value, "these two should be equal as this category does not own any stock"
    
    total = 0.0
    for category in consumable_categories(:child).consumable_category.children
      total += category.stock_value
    end    
    assert_equal total, consumable_categories(:child).consumable_category.stock_value, "its stock value should be equal to the total of its categories stock value"
    
    total = 0.0
    for consumable in consumable_categories(:child).consumables
      total += consumable.stock_value
    end    
    assert_equal total, consumable_categories(:child).stock_value, "its stock value should be equal to the total of its consumables stock value"
  end
end
