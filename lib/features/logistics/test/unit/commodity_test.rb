require 'test/test_helper'
require File.dirname(__FILE__) + '/supply_test'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/new_stock_flow'

class CommodityTest < ActiveSupport::TestCase
  include SupplyTest
  include NewStockFlow

  def setup   
    @supply_category = CommodityCategory.new(:name => "root")
    flunk "@supply_category should be valid to perform the next tests" unless @supply_category.save    
    @supply = Commodity.new
    @supply.valid? 
  end  
  
  def test_presence_of_commodity_category_id
    assert @supply.errors.on(:commodity_category_id), "@supply should NOT be valid because commodity_category_id is nil"
    
    @supply.commodity_category_id = 0
    @supply.valid?
    assert !@supply.errors.on(:commodity_category_id), "@supply should be valid"
    assert @supply.errors.on(:commodity_category), "@supply should be valid"
    
    @supply.commodity_category_id = @supply_category.id
    @supply.valid?
    assert !@supply.errors.on(:commodity_category_id), "@supply should be valid"
    assert !@supply.errors.on(:commodity_category), "@supply should be valid"
    
    @supply.commodity_category = @supply_category
    @supply.valid?
    assert !@supply.errors.on(:commodity_category_id), "@supply should be valid"
    assert !@supply.errors.on(:commodity_category), "@supply should be valid"
  end    
  
  include CreateSupplies 
  
  def test_uniqueness_of_name
    create_commodities
    @supply.name = "Galva"
    @supply.valid?
    
    assert @supply.errors.on(:name), "@supply should NOT be valid because name is already taken"
  end
  
  def test_uniqueness_of_reference
    create_commodities
    @supply.reference = "glv1234"
    @supply.valid?
    
    assert @supply.errors.on(:reference), "@supply should NOT be valid because reference is already taken"
  end
  
  def test_has_supplier_supplies
    create_supplier_commodities     
    assert_equal @galva.supplier_supplies, [@galva_ss], "[@galva_ss] should be @galva.supplier_supplies"                                          
  end
  
  def test_has_supplies
    create_supplier_commodities 
    assert_equal [Supplier.last], @galva.suppliers, "[Supplier.last] should be @galva.suppliers"
  end
end
