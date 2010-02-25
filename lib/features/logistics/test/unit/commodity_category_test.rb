require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'
require File.dirname(__FILE__) + '/new_stock_flow'

class CommodityCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  include NewStockFlow
  
  def setup
    @supply = Commodity.new
  
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid" unless @um.save
    
    @supply_category = CommodityCategory.new({:name => "root"})
    flunk "@supply_category should be valid" unless @supply_category.save
    
    @supply_category_with_parent = CommodityCategory.new({:name => "child", :parent => @supply_category, :unit_measure_id => @um.id})
    flunk "@supply_category_with_parent should be valid" unless @supply_category_with_parent.save
  end

  def test_has_many_supplies
    create_commodities
    assert_equal supply_categories(:child_commodity).supplies, [@galva,@acier], "This CommodityCategory should have these supplies"
  end
  
  def test_has_many_enabled_and_disabled_supplies
    create_supplier_supplies
    flunk "stock flow must be saved" unless new_stock_flow(@galva,@galva.suppliers.first,true,5)
    sleep(1)
    flunk "stock flow must be saved" unless new_stock_flow(@galva,@galva.suppliers.first,false,5)
    flunk "@pvc should be disabled" unless @galva.disable
    
    assert_equal supply_categories(:child_commodity).enabled_supplies, [@acier], "This CommodityCategory should have these enabled supplies"
    assert_equal supply_categories(:child_commodity).disabled_supplies, [@galva], "This CommodityCategory should have these disabled supplies"
  end
  
  def test_has_many_enabled_and_disabled_categories
    @another_supply_category = CommodityCategory.new({:name => "second_child", :parent => @supply_category, :unit_measure_id => @um.id })
    flunk "@another_supply_category should be valid" unless @another_supply_category.save
    flunk "@another_supply_category should be disabled" unless @another_supply_category.disable
    
    assert_equal @supply_category.enabled_categories, [@supply_category_with_parent], "This CommodityCategory should have these enabled categories"
    assert_equal @supply_category.disabled_categories, [@another_supply_category], "This CommodityCategory should have these disabled categories"  
  end
end
