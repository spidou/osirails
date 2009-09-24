require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/supply_category_test'

class CommodityCategoryTest < ActiveSupport::TestCase
  include CreateSupplies
  include SupplyCategoryTest
  
  def setup
    @supply = Commodity.new
  
    @um = UnitMeasure.new({:name => "Millimètre", :symbol => "mm"})
    flunk "@um should be valid to perform the next tests" unless @um.save
    
    @supply_category = CommodityCategory.new({:name => "root"})
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save
    
    @supply_category_with_parent = CommodityCategory.new({:name => "child", :commodity_category => @supply_category, :unit_measure_id => @um.id})
    flunk "@supply_category_with_parent should be valid to perform the next tests" unless @supply_category_with_parent.save
  end

  def test_has_many_commodities
    create_commodities
    assert_equal commodity_categories(:child).commodities, [@galva,@acier], "This CommodityCategory should have these commodities"
  end
end
