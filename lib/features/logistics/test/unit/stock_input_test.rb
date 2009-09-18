require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/stock_flow_test'
require File.dirname(__FILE__) + '/new_stock_flow'

class StockInputTest < ActiveSupport::TestCase
  include StockFlowTest
  include NewStockFlow

  def setup
    @sf = StockInput.new
    @sf.valid?
  end

  def test_presence_of_purchase_number
    assert @sf.errors.on(:purchase_number), "purchase_number should NOT be valid because it is nil"

    @sf.purchase_number = "x"
    @sf.valid?
    assert !@sf.errors.on(:purchase_number), "purchase_number should be valid"

    @sf.adjustment = true
    @sf.purchase_number = nil
    @sf.valid?
    assert !@sf.errors.on(:purchase_number), "purchase_number should be valid"
  end

  def test_numericality_of_fob_unit_price
    assert @sf.errors.on(:fob_unit_price), "fob_unit_price should NOT be valid because it is nil"

    @sf.adjustment = true
    @sf.valid?
    assert !@sf.errors.on(:fob_unit_price), "purchase_number should be valid"

    @sf.adjustment = false
    @sf.fob_unit_price = "x"
    @sf.valid?
    assert @sf.errors.on(:fob_unit_price), "fob_unit_price should NOT be valid because it is not a number"

    @sf.fob_unit_price = 1
    @sf.valid?
    assert !@sf.errors.on(:fob_unit_price), "fob_unit_price should be valid"
  end

  def test_numericality_of_tax_coefficient
    assert @sf.errors.on(:tax_coefficient), "tax_coefficient should NOT be valid because it is nil"

    @sf.adjustment = true
    @sf.valid?
    assert !@sf.errors.on(:tax_coefficient), "tax_coefficient should be valid"

    @sf.adjustment = false
    @sf.tax_coefficient = "x"
    @sf.valid?
    assert @sf.errors.on(:tax_coefficient), "tax_coefficient should NOT be valid because it is not a number"

    @sf.tax_coefficient = 1
    @sf.valid?
    assert !@sf.errors.on(:tax_coefficient), "tax_coefficient should be valid"
  end

  def test_create_stock_input
    create_supplier_supplies

    assert_difference "StockInput.count", 2 do
      new_stock_flow(Supply.last,Supplier.last,true,10)
      new_stock_flow(Supply.last,Supplier.last,true,10,true) #with adjustment
    end
  end  
  
  def test_before_create
    create_supplier_supplies
    @stock_quantity = Supply.last.stock_quantity
    @stock_value = Supply.last.stock_value
    flunk "stock input must be done to perform this test" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    @last_sf = StockFlow.last
    assert_equal @last_sf.previous_stock_quantity, @stock_quantity, "these two should be equal"
    assert_equal @last_sf.previous_stock_value, @stock_value, "these two should be equal"
  end
end

