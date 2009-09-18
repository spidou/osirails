require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'

class CommodityCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  
  def setup
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid to perform the next tests" unless @um.save
    
    @supply_category = CommodityCategory.new({:name => "root"})
    @supply_category_with_parent = CommodityCategory.new({:name => "child", :commodity_category => @supply_category, :unit_measure_id => @um.id})
    
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save
    flunk "@supply_category_with_parent should be valid to perform the next tests" unless @supply_category_with_parent.save
  end

  def test_has_many_commodity_categories
    assert_equal @supply_category.commodity_categories, [@supply_category_with_parent],
      "@supply_category should have a child commodity category"
  end

  def test_has_many_commodities
    create_commodities
    assert_equal commodity_categories(:child).commodities, [@galva,@acier], "This CommodityCategory should have these commodities"
  end

  def test_belongs_to_commodity_category
    assert_equal @supply_category_with_parent.commodity_category, @supply_category, "@supply_category_with_parent should have a parent"
  end  
  
  def test_stock_value
    @cc = CommodityCategory.new
    assert_equal 0.0, @cc.stock_value, "these two should be equal as this category does not own any stock"
    
    total = 0.0
    for category in commodity_categories(:child).commodity_category.children
      total += category.stock_value
    end    
    assert_equal total, commodity_categories(:child).commodity_category.stock_value, "its stock value should be equal to the total of its categories stock value"
    
    total = 0.0
    for commodity in commodity_categories(:child).commodities
      total += commodity.stock_value
    end    
    assert_equal total, commodity_categories(:child).stock_value, "its stock value should be equal to the total of its commodities stock value"
  end
end
