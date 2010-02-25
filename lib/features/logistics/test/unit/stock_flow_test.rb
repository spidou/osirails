module StockFlowTest
  include CreateSupplies

  def test_presence_of_supply_id
    assert @sf.errors.on(:supply_id), "supply_id should NOT be valid because it is nil"

    create_supplier_supplies
    @sf.supply_id = 0
    @sf.valid?
    assert !@sf.errors.on(:supply_id), "supply_id should be valid"
    assert @sf.errors.on(:supply), "supply should NOT be valid because it does not exist"


    @sf.supply_id = Supply.last.id
    @sf.valid?
    assert !@sf.errors.on(:supply_id), "supply_id should be valid"
    assert !@sf.errors.on(:supply), "supply should be valid"

    @sf.supply = Supply.last
    @sf.valid?
    assert !@sf.errors.on(:supply_id), "supply_id should be valid"
    assert !@sf.errors.on(:supply), "supply should be valid"
  end

  def test_presence_of_supplier_id
    assert @sf.errors.on(:supplier_id), "supplier_id should NOT be valid because it is nil"

    @sf.supplier_id = 0
    @sf.valid?
    assert !@sf.errors.on(:supplier_id), "supplier_id should be valid"
    assert @sf.errors.on(:supplier), "supplier should NOT be valid because it does not exist"


    @sf.supplier_id = Supplier.last.id
    @sf.valid?
    assert !@sf.errors.on(:supplier_id), "supplier_id should be valid"
    assert !@sf.errors.on(:supplier), "supplier should be valid"

    @sf.supplier = Supplier.last
    @sf.valid?
    assert !@sf.errors.on(:supplier_id), "supplier_id should be valid"
    assert !@sf.errors.on(:supplier), "supplier should be valid"
  end

  def test_presence_of_supplier_supply
    assert @sf.errors.on(:supplier_supply), "supplier_supply should NOT be valid because it is nil"
    create_supplier_commodities
    @sf.supplier = Supplier.last
    @sf.supply = Supply.last
    @sf.valid?
    assert !@sf.errors.on(:supplier_supply), "supplier_supply should be valid"
  end

  def test_numericality_of_quantity
    assert @sf.errors.on(:quantity), "quantity should NOT be valid because it is nil"

    @sf.quantity = "x"
    @sf.valid?
    assert @sf.errors.on(:quantity), "quantity should NOT be valid because it is not a number"

    @sf.quantity = -5
    @sf.valid?
    assert @sf.errors.on(:quantity), "quantity should NOT be valid because it must be greater than 0"

    @sf.quantity = 0
    @sf.valid?
    assert @sf.errors.on(:quantity), "quantity should NOT be valid because it must be greater than 0"

    @sf.quantity = 1
    @sf.valid?
    assert !@sf.errors.on(:quantity), "quantity should be valid"
  end

  def test_supplier_supply
    create_supplier_supplies
    flunk "stock flow must be saved" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    assert_equal @sf.supplier_supply, SupplierSupply.find_by_supply_id(Supply.last.id, :conditions => ["supplier_id = ?", Supplier.last.id]), "this should be @sf.supplier_supply"
  end

  def test_suppply
    create_supplier_supplies
    flunk "stock flow must be saved" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    assert_equal @sf.supply, Supply.find(Supply.last.id), "this should be @sf.supply"
  end

  def test_supplier
    create_supplier_supplies
    flunk "stock flow must be saved" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    assert_equal @sf.supplier, Supplier.find(Supplier.last.id), "this should be @sf.supplier"
  end

  def test_before_update
    create_supplier_supplies
    flunk "stock input must be done" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    @last_sf = StockFlow.last
    assert !@last_sf.save, "@last_sf should NOT be able to save because update is blocked"
  end
  
  def test_unit_price
    create_supplier_supplies
    flunk "stock input must be done" unless new_stock_flow(Supply.last,Supplier.last,true,10)
    assert_equal StockFlow.last.unit_price, StockFlow.last.fob_unit_price * (1+StockFlow.last.tax_coefficient/100), "these two should be equal"
  end
end
