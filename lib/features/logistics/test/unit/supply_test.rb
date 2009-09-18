module SupplyTest
  def test_presence_of_name
    assert @supply.errors.on(:name), "@supply should NOT be valid because name is nil"

    @supply.name = "metal"
    @supply.valid?
    assert !@supply.errors.on(:name), "@supply should be valid"
  end

  def test_presence_of_reference
    assert @supply.errors.on(:reference), "@supply should NOT be valid because reference is nil"

    @supply.reference = "mtu1234"
    @supply.valid?
    assert !@supply.errors.on(:reference), "@supply should be valid"
  end

  def test_numericality_of_unit_mass
    assert @supply.errors.on(:unit_mass), "@supply should NOT be valid because unit_mass is nil"

    @supply.unit_mass = "x"
    @supply.valid?
    assert @supply.errors.on(:unit_mass), "@supply should NOT be valid because unit_mass is not a number"

    @supply.unit_mass = 60
    @supply.valid?
    assert !@supply.errors.on(:unit_mass), "@supply should be valid"
  end

  def test_numericality_of_measure
    assert @supply.errors.on(:measure), "@supply should NOT be valid because measure is nil"

    @supply.measure = 4.5
    @supply.valid?
    assert !@supply.errors.on(:measure), "@supply should be valid"

    @supply.measure = "x"
    @supply.valid?
    assert @supply.errors.on(:measure), "@supply should NOT be valid because measure is not a number"
  end

  def test_numericality_of_threshold
    assert @supply.errors.on(:threshold), "@supply should NOT be valid because threshold is nil"

    @supply.threshold = 15
    @supply.valid?
    assert !@supply.errors.on(:threshold), "@supply should be valid"

    @supply.threshold = "x"
    @supply.valid?
    assert @supply.errors.on(:threshold), "@supply should NOT be valid because threshold is not a number"
  end

  def test_stock_flows
    create_supplier_supplies
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@vis,@vis_ss.supplier,true,10)
    assert_equal @vis.stock_flows, StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ?", @vis.id, @vis_ss.supplier.id]), "this should be @vis.stock_flows"
  end

  def test_restockables
    create_supplier_supplies
    assert_equal Supply.restockables, Supply.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"

    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,10)
    sleep(1)
    assert_equal Supply.restockables, Supply.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,3)
    sleep(1)
    assert_equal Supply.restockables, Supply.find(:all), "restockables are all supplies as their stock are 0 (under threshold*1.1)"
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@galva,@galva_ss.supplier,true,12)
    assert Supply.restockables != Supply.find(:all), "restockables are NOT all supplies as @galva is not a restockable anymore"
    assert !Supply.restockables.include?(Supply.find(@galva.id)), "@galva should NOT be included in restockables as its stock is 25 (above threshold*1.1)"
  end

  def test_average_unit_price
    assert_equal nil, @supply.average_unit_price, "@supply.average_unit_price should be nil as he does not own any stock"
    
    create_supplier_supplies
    @supply = Supply.last
    
    total = 0.0
    for supplier_supply in @supply.supplier_supplies
      total += supplier_supply.average_unit_price
    end
    
    assert_equal total/@supply.supplier_supplies.size, @supply.average_unit_price, "these two should be equal because there is not any stock flow"
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5,false,Date.today-50)

    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_quantity(Date.today-50) * f.average_unit_price(Date.today-50)
    end
    assert_equal total/(@supply.stock_quantity(Date.today-50)*@supply.measure), @supply.average_unit_price(Date.today-50), "@supply.average_unit_price should be the average of its supplier_supplies"    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)

    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_quantity * f.average_unit_price
    end
    assert_equal total/(@supply.stock_quantity*@supply.measure), @supply.average_unit_price, "@supply.average_unit_price should be the average of its supplier_supplies' unit price"
  end

  def test_stock_value
    assert_equal 0, @supply.stock_value, "@supply.stock_value should be nil as he does not own any stock"

    create_supplier_supplies
    @supply = Supply.last
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5,false,Date.today-50)

    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_value(Date.today-50)
    end
    assert_equal total, @supply.stock_value(Date.today-50), "@supply.stock_value should be the sum of its supplier_supplies' stock_value"

    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)

    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_value
    end
    assert_equal total, @supply.stock_value, "@supply.stock_value should be the sum of its supplier_supplies' stock_value"
  end


  def test_stock_quantity
    assert_equal 0.0, @supply.stock_quantity, "@supply.stock_quantity should be 0.0 as he does not own any supplier_supplies"

    create_supplier_supplies
    @supply = Supply.last
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5,false,Date.today-50)
    
    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_quantity(Date.today-50)
    end
    assert_equal total, @supply.stock_quantity(Date.today-50), "@supply.stock_quantity should be the total of its supplier_supplies' stock_quantity"
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)
    
    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_quantityflunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)

    total = 0.0
    for f in @supply.supplier_supplies
      total += f.stock_quantity * f.average_unit_price
    end
    end
    assert_equal total, @supply.stock_quantity, "@supply.stock_quantity should be the total of its supplier_supplies' stock_quantity"
  end
end

