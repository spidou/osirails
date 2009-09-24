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
  
  def test_has_been_used
    create_supplier_supplies
    @supply = Supply.last
    
    assert !@supply.has_been_used?, "@supply should NOT have been used because there is no stock flow"
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)
    assert @supply.has_been_used?, "@supply should have been used"
  end
  
  def test_persistent_attributes_when_already_used_supply
    create_supplier_supplies
    @supply = Supply.last
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)
    
    persistent_attributes = ["name", "reference", "measure", "unit_mass", "commodity_category_id", "consumable_category_id"]
    
    for element in persistent_attributes
      @supply.send("#{element}=",99999)
    end
    
    assert @supply.persistence_case?, "@supply should be in a persistent case because it has been used"
    assert !@supply.valid?, "@supply should NOT be valid because its attributes should be persistent"
    
    for element in persistent_attributes
      assert @supply.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end
  end  
  
  def test_persistent_attributes_when_disabled_supply
    create_supplier_supplies
    @supply = Supply.last
    flunk "@supply must be disabled with success to perform this test method" unless @supply.disable
    
    persistent_attributes = ["name", "reference", "measure", "unit_mass", "commodity_category_id", "consumable_category_id"]
    
    for element in persistent_attributes
      @supply.send("#{element}=",99999)
    end
    
    assert @supply.persistence_case?, "@supply should be in a persistent case because it is disabled"
    assert !@supply.valid?, "@supply should NOT be valid because its attributes should be persistent"
    
    for element in persistent_attributes
      assert @supply.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end
  end
  
  def test_disable_and_was_enabled_at
    create_supplier_supplies
    @supply = Supply.last
    
    assert @supply.can_be_disabled?, "@supply should be able to be disabled"
    flunk "@supply must be disabled with success to perform this test method" unless @supply.disable
    assert_equal false, @supply.enable, "these two should be equal because @supply has been disabled"
    assert !@supply.class.name.constantize.was_enabled_at.include?(@supply), "@supply should not be included in was_enabled_at because it's not enabled"
    assert @supply.class.name.constantize.was_enabled_at(Date.yesterday).include?(@supply), "@supply should be included in was_enabled_at(Date.yesterday) because it was enabled"
  
    assert !@supply.can_be_disabled?, "@supply should NOT be able to be disabled because it is still disabled"
    assert !@supply.disable, "@supply should fail at disable because it cannot be disabled"
  end
  
  def test_disable_when_supply_not_been_used
    create_supplier_supplies
    @supply = Supply.first
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,@supply.suppliers.first,true,5)
    assert !@supply.can_be_disabled?, "@supply should NOT be able to be disabled because stock_quantity > 0"
    assert !@supply.disable, "@supply should fail at disable because it cannot be disabled"
    sleep(1)
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,@supply.suppliers.first,false,5)
    assert @supply.can_be_disabled?, "@supply should be able to be disabled"
    assert @supply.disable, "@supply should be disabled now its stock is 0"
  end
  
  def test_destroy
    create_supplier_supplies
    @supply = Supply.last
    
    flunk "stock flow must be saved with success to perform this test method" unless new_stock_flow(@supply,Supplier.last,true,5)
    assert !@supply.can_be_destroyed?, "@supply should NOT be able to be destroyed because it has been used"
    assert !@supply.destroy, "@supply should NOT be destroyed because it cannot be destroyed"
    
    @supply = Supply.first
    
    assert @supply.can_be_destroyed?, "@supply should be able to be destroyed"
    assert @supply.destroy,"@supply should destroy with success"
  end
  
  def test_reactivate
    create_supplier_supplies
    @supply = Supply.last
    
    assert !@supply.can_be_reactivated?, "@supply should NOT be able to be reactivated because it is still enabled"
    assert !@supply.reactivate, "@supply should fail at reactivate because it cannot be reactivated"
    
    flunk "@supply must be disabled with success to perform this test method" unless @supply.disable
    assert @supply.can_be_reactivated?, "@supply should be able to be reactivated because it is disabled, and its category is still enabled"
   
    flunk "@supply must be reactivated with success to perform this test method" unless @supply.reactivate
    assert_equal true, @supply.enable, "these two should be equal because @supply has been ractivated"
    assert_equal nil, @supply.disabled_at, "these two should be equal because @supply has been ractivated"
  end
  
  def test_reactivate_when_category_disabled
    create_supplier_supplies
    flunk "Supply.last must destroy with success to perform this test method" unless Supply.last.destroy # To keep only one supply in the category
    @supply = Supply.last
    
    flunk "@supply must be disabled with success to perform this test method" unless @supply.disable
    category = @supply.send((@supply.class.name+"Category").underscore)
    flunk "@supply.category must be disabled with success to perform this test method" unless category.disable
    
    assert !@supply.can_be_reactivated?, "@supply should NOT be able to be reactivated because and its category is disabled"
    assert !@supply.reactivate, "@supply should fail at reactivate because it cannot be reactivated"
  end
end

