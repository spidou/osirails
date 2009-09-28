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
    assert @supply.errors.on(:supply_category), "@supply should be valid"
    
    @supply.commodity_category_id = @supply_category.id
    @supply.valid?
    assert !@supply.errors.on(:commodity_category_id), "@supply should be valid"
    assert !@supply.errors.on(:supply_category), "@supply should be valid"
    
    @supply.supply_category = @supply_category
    @supply.valid?
    assert !@supply.errors.on(:commodity_category_id), "@supply should be valid"
    assert !@supply.errors.on(:supply_category), "@supply should be valid"
  end    
  
  include CreateSupplies 
  
  def test_uniqueness_of_name
    create_commodities
    create_consumables
    @supply.name = "Galva"
    @supply.valid?
    
    assert @supply.errors.on(:name), "@supply should NOT be valid because name is already taken"
    
    @supply.name = "PVC"
    @supply.valid?
    
    assert !@supply.errors.on(:name), "@supply should be valid"
  end
  
  def test_uniqueness_of_reference
    create_commodities
    create_consumables
    @supply.reference = "glv1234"
    @supply.valid?
    
    assert @supply.errors.on(:reference), "@supply should NOT be valid because reference is already taken"
    
    @supply.reference = "pvc1234"
    @supply.valid?
    
    assert !@supply.errors.on(:reference), "@supply should be valid"
  end  

  def test_restockables
    create_supplier_supplies
    assert_equal Commodity.restockables, Commodity.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"

    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,10)
    sleep(1)
    
    assert_equal Commodity.restockables, Commodity.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,3)
    sleep(1)
    
    assert_equal Commodity.restockables, Commodity.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"
   
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,12)
    
    assert Commodity.restockables != Commodity.find(:all), "restockables are NOT all supplies as @galva is not a restockable anymore"
    assert !Commodity.restockables.include?(Commodity.find(@galva.id)), "@galva should NOT be included in restockables as its stock is 25 (above threshold*1.1)"
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
