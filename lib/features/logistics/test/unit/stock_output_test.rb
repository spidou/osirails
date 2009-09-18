require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/stock_flow_test'
require File.dirname(__FILE__) + '/new_stock_flow'

class StockOutputTest < ActiveSupport::TestCase
  include StockFlowTest
  include NewStockFlow

   def setup
    @sf = StockOutput.new
    @sf.valid?
  end

   def test_presence_of_file_number
    assert @sf.errors.on(:file_number), "file_number should NOT be valid because it is nil"

    @sf.file_number = "x"
    @sf.valid?
    assert !@sf.errors.on(:file_number), "file_number should be valid"

    @sf.adjustment = true
    @sf.file_number = nil
    @sf.valid?
    assert !@sf.errors.on(:file_number), "file_number should be valid"
  end

  def test_create_stock_output
    create_supplier_supplies
    flunk "stock input must be done to perform this test" unless new_stock_flow(Supply.last,Supplier.last,true,10)

    assert_difference "StockOutput.count", 2 do
      new_stock_flow(Supply.last,Supplier.last,false,5)
      new_stock_flow(Supply.last,Supplier.last,false,5,true) #with adjustment
    end
  end

  def test_stock_availability
    create_supplier_supplies
    assert_no_difference "StockOutput.count" do
      new_stock_flow(Supply.last,Supplier.last,false,10)
    end
    assert @sf.errors.on(:quantity), "quantity should NOT be valid because it is greater than supplier_supply's stock"
  end

  def test_before_create
    create_supplier_supplies
    flunk "stock input must be done to perform this test" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    @stock_quantity = Supply.last.stock_quantity
    @stock_value = Supply.last.stock_value
    @aup = Supply.last.average_unit_price
    flunk "stock output must be done to perform this test" unless new_stock_flow(Supply.last,Supplier.last,false,5)
    @last_sf = StockFlow.last
    assert_equal @last_sf.previous_stock_quantity, @stock_quantity, "these two should be equal"
    assert_equal @last_sf.previous_stock_value, @stock_value, "these two should be equal"
    assert_equal @last_sf.fob_unit_price, @aup, "these two should be equal"
    assert_equal @last_sf.tax_coefficient, 0, "these two should be equal"
  end
end

