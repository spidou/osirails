require 'test/test_helper'
require File.dirname(__FILE__) + '/create_supplies'
require File.dirname(__FILE__) + '/new_stock_flow'

class SupplierTest < ActiveSupport::TestCase
  include CreateSupplies
  include NewStockFlow

  def setup
    @supplier = Supplier.first
    create_supplier_supplies
  end

  def test_supplies
    supplies = []
    supplier_supplies = SupplierSupply.find(:all, :conditions => ["supplier_id", @supplier.id])
    for element in supplier_supplies
      supplies << element.supply
    end
    assert_equal @supplier.supplies, supplies, "these should be @supplier.supplies"
  end

  def test_supplier_supplies
    assert_equal @supplier.supplier_supplies, SupplierSupply.find(:all, :conditions => ["supplier_id", @supplier.id]), "these should be @supplier.supplier_supplies"
  end

  def test_stock_flows
    assert_equal @supplier.stock_flows, StockFlow.find(:all, :conditions => ["supplier_id", @supplier.id]), "these should be @supplier.stock_flows"
  end
end

