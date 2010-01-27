require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/new_stock_flow'

class SupplierSupplyTest < ActiveSupport::TestCase
  include CreateSupplies

  def setup
    @ss = SupplierSupply.new
    @ss.valid?
  end

  def test_uniqueness_of_the_pair_keys
    create_commodities
    @ss = SupplierSupply.new({:supply_id => Supply.last.id,
                              :supplier_id => Supplier.last.id,
                              :reference => "glv",
                              :name => "Gavla",
                              :lead_time => 15,
                              :fob_unit_price => 50,
                              :tax_coefficient => 0.5})
    assert @ss.save, "@ss should be created with success"

    @another_ss = SupplierSupply.new
    @another_ss.supply_id = Supply.last.id
    @another_ss.supplier_id = Supplier.last.id
    @another_ss.valid?
    assert @another_ss.errors.on(:supplier_id), "@ss should NOT be valid"

    @another_ss.supplier_id = 2
    @another_ss.valid?
    assert !@another_ss.errors.on(:supplier_id), "@ss should be valid"

    @another_ss.supplier_id = Supplier.last.id
    @another_ss.supply_id = 2
    @another_ss.valid?
    assert !@another_ss.errors.on(:supplier_id), "@ss should be valid"
  end

  def test_presence_of_supplier_id
    assert @ss.errors.on(:supplier_id), "@ss should NOT be valid because supplier_id is nil"

    @ss.supplier_id = 1
    @ss.valid?
    assert !@ss.errors.on(:supplier_id), "@ss should be valid"
  end

  def test_presence_of_reference
    assert @ss.errors.on(:reference), "@ss should NOT be valid because reference is nil"

    @ss.reference = "glv"
    @ss.valid?
    assert !@ss.errors.on(:reference), "@ss should be valid"
  end

  def test_presence_of_name
    assert @ss.errors.on(:name), "@ss should NOT be valid because name is nil"

    @ss.name = "Galva"
    @ss.valid?
    assert !@ss.errors.on(:name), "@ss should be valid"
  end

  def test_numericality_of_lead_time
    assert @ss.errors.on(:lead_time), "@ss should NOT be valid because lead_time is nil"

    @ss.lead_time = -1
    @ss.valid?
    assert @ss.errors.on(:lead_time), "@ss should NOT be valid because lead_time is under 0"

    @ss.lead_time = "x"
    @ss.valid?
    assert @ss.errors.on(:lead_time), "@ss should NOT be valid because lead_time is not a number"

    @ss.lead_time = 0
    @ss.valid?
    assert !@ss.errors.on(:lead_time), "@ss should be valid"
  end

  def test_numericality_of_fob_unit_price
    assert @ss.errors.on(:fob_unit_price), "@ss should NOT be valid because fob_unit_price is nil"

    @ss.fob_unit_price = -1
    @ss.valid?
    assert @ss.errors.on(:fob_unit_price), "@ss should NOT be valid because fob_unit_priceis under 0"

    @ss.fob_unit_price = "x"
    @ss.valid?
    assert @ss.errors.on(:fob_unit_price), "@ss should NOT be valid because fob_unit_price is not a number"

    @ss.fob_unit_price = 0
    @ss.valid?
    assert !@ss.errors.on(:fob_unit_price), "@ss should be valid"
  end

  def test_numericality_of_tax_coefficient
    assert @ss.errors.on(:tax_coefficient), "@ss should NOT be valid because tax_coefficient is nil"

    @ss.tax_coefficient = -1
    @ss.valid?
    assert @ss.errors.on(:tax_coefficient), "@ss should NOT be valid because tax_coefficient is under 0"

    @ss.tax_coefficient = "x"
    @ss.valid?
    assert @ss.errors.on(:tax_coefficient), "@ss should NOT be valid because tax_coefficient is not a number"

    @ss.tax_coefficient = 0
    @ss.valid?
    assert !@ss.errors.on(:tax_coefficient), "@ss should be valid"
  end

  include NewStockFlow

  def test_stock_flows
    create_supplier_supplies
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,10)
    assert_equal @vis_ss.stock_flows, StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ?", @vis_ss.supply.id, @vis_ss.supplier.id]), "this should be @vis_ss.stock_flows"
  end

  def test_average_unit_price_and_stock_quantity_and_stock_value_over_time
    create_supplier_supplies

    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,10,false,Date.today-50)
    sleep(0.5)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,10,true,Date.today-20) #with adjustment
    sleep(0.5)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,false,10)
    
    
    @ss = SupplierSupply.find(@vis_ss.id)
   
    assert_equal 10, @ss.stock_quantity(Date.today-50), "these two should be equal"
    assert_equal @ss.stock_quantity(Date.today-50)+10, @ss.stock_quantity(Date.today-20), "these two should be equal"
    assert_equal @ss.stock_quantity(Date.today-20)-10, @ss.stock_quantity, "these two should be equal"
  
    assert_equal @ss.supply.measure*10, @ss.stock_value(Date.today-50), "these two should be equal"
    assert_equal @ss.supply.measure*10*@ss.average_unit_price(Date.today-20)+10, @ss.stock_value(Date.today-20), "these two should be equal"
    assert_equal @ss.supply.measure*@ss.stock_value(Date.today-20)-10*@ss.average_unit_price, @ss.stock_value, "these two should be equal"
  
    assert_equal @ss.stock_value(Date.today-50)/(@ss.stock_quantity(Date.today-50)*@ss.supply.measure), @ss.average_unit_price(Date.today-50), "these two should be equal"
    assert_equal @ss.stock_value(Date.today-20)/(@ss.stock_quantity(Date.today-20)*@ss.supply.measure), @ss.average_unit_price(Date.today-20), "these two should be equal"
    assert_equal @ss.stock_value/(@ss.stock_quantity*@ss.supply.measure), @ss.average_unit_price, "these two should be equal"
    
    assert_equal 0, @ss.previous_stock_quantity(Date.today-50), "these two should be equal"
    assert_equal 10, @ss.previous_stock_quantity(Date.today-20), "these two should be equal"
    assert_equal 20, @ss.previous_stock_quantity, "these two should be equal"

    assert_equal @ss.supply.measure*10, @ss.previous_stock_value(Date.today-20), "these two should be equal"
    assert_equal @ss.supply.measure*10*@ss.average_unit_price(Date.today-20)+10, @ss.previous_stock_value, "these two should be equal"
  end
  
  def test_empty_stock
    create_supplier_supplies
  
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,3900000,false,Date.today,1,0)
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,1000000,true,Date.today,5,0) #with adjustment
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,false,3000000,false,Date.today)
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,true,2000000,true,Date.today,7,0) #with adjustment
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis_ss.supply,@vis_ss.supplier,false,3900000,false,Date.today)
    assert_equal 0.0, @vis_ss.stock_quantity.to_f, "these two should be equal as the stock has been emptied"
    assert_equal 0.0, @vis_ss.stock_value.to_f, "these two should be equal as the stock has been emptied"
    assert_equal 0.0, @vis_ss.average_unit_price.to_f, "these two should be equal as the stock has been emptied"
  end
end

