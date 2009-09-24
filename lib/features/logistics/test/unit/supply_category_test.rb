module SupplyCategoryTest  
  def test_presence_of_name
    @supply_category_without_name = @supply_category.class.send("new")
    @supply_category_without_name.valid?
    assert @supply_category_without_name.errors.on(:name), "This supply category should NOT be valid because name is nil"
    
    @supply_category_without_name.name = "Hello World"
    @supply_category_without_name.valid?
    assert !@supply_category_without_name.errors.on(:name), "This supply category should be valid"
  end
  
  def test_uniqueness_of_name
    @supply_category_with_name = @supply_category.class.send("new",{:name => "root"})
    @supply_category_with_name.valid?
    assert @supply_category_with_name.errors.on(:name), "This supply category should NOT be valid because name is already taken"
  end
  
  def test_presence_of_unit_measure_id
    @supply_category_without_um = @supply_category.class.send("new",{(@supply_category.class.name.underscore+"_id").to_sym => @supply_category.id})
    @supply_category_without_um.valid?
    assert @supply_category_without_um.errors.on(:unit_measure_id), "This supply category should NOT be valid because unit_measure_id is nil"
    
    @supply_category_without_um.unit_measure_id = @um.id
    @supply_category_without_um.valid?
    assert !@supply_category_without_um.errors.on(:unit_measure_id), "unit_measure_id should be valid"
  end
  
  def test_persistent_attributes_when_disable
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    
    persistent_attributes = ["name", "#{@supply_category.class.name.underscore+"_id"}", "unit_measure_id"]
    
    for element in persistent_attributes
      @supply_category_with_parent.send("#{element}=",99999)
    end
    
    assert !@supply_category_with_parent.valid?, "@supply_category should NOT be valid because its attributes should be persistent"
    
    for element in persistent_attributes
      assert @supply_category_with_parent.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end
  end
  
  def test_root
    assert @supply_category.class.name.constantize.root.include?(@supply_category), "@supply_category should be included in Category.root"
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    flunk "@supply_category must be disabled with success to perform this test method" unless @supply_category.disable
    
    assert !@supply_category.class.name.constantize.root.include?(@supply_category), "@supply_category should NOT be included in Category.root because it is disabled"
  end
  
  def test_root_including_inactives
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    flunk "@supply_category must be disabled with success to perform this test method" unless @supply_category.disable
    
    assert @supply_category.class.name.constantize.root_including_inactives.include?(@supply_category), "@supply_category should be included in Category.root_including_inactives"
  end
  
  def test_root_child
    assert @supply_category_with_parent.class.name.constantize.root_child.include?(@supply_category_with_parent), "@supply_category_with_parent should be included in Category.root_child"
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
  
    assert !@supply_category_with_parent.class.name.constantize.root_child.include?(@supply_category_with_parent), "@supply_category_with_parent should NOT be included in Category.root_child because it is disabled"
  end
  
  def test_disable_root_child
    assert @supply_category_with_parent.can_be_disabled?, "it should be able to be disabled"
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    assert_equal false, @supply_category_with_parent.enable, "these two should be equal because @supply_category_with_parent has been disabled"
    assert !@supply_category_with_parent.class.name.constantize.was_enabled_at.include?(@supply_category_with_parent), "@supply_category_with_parent should not be included in was_enabled_at because it's not enabled"
    assert @supply_category_with_parent.class.name.constantize.was_enabled_at(Date.yesterday).include?(@supply_category_with_parent), "@supply_category_with_parent should be included in was_enabled_at(Date.yesterday) because it was enabled"
  end
  
  def test_disable_root_child_when_supplies_in
    self.send("create_"+@supply.class.name.tableize)
    @supply_category_root_child = @supply.class.last.send(@supply_category.class.name.underscore)
    
    assert !@supply_category_root_child.can_be_disabled?, "it should NOT be able to be disabled because it has supplies"
    assert !@supply_category_root_child.disable, "it should fail at disable because it cannot be disabled"
    
    for supply in @supply_category_root_child.send(@supply.class.name.tableize)
      flunk "supply should disable with success to perform this test" unless supply.disable
    end
    
    assert @supply_category_root_child.can_be_disabled?, "it should be able to be disabled"
    assert @supply_category_root_child.disable, "it should disable with success"
  end
  
  def test_disable_root
    assert !@supply_category.can_be_disabled?, "it should NOT be able to be disabled because it has one children enabled"
    assert !@supply_category.disable, "@supply_category should NOT be disabled because it cannot be disabled"
    
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    assert @supply_category.can_be_disabled?, "it should be able to be disabled"
    assert @supply_category.disable, "@supply_category should be disabled because it can be disabled"
  end
  
  def test_destroy_root_child
    assert @supply_category_with_parent.can_be_destroyed?, "it should be able to be destroyed"
    flunk "@supply_category_with_parent must be destroyed with success to perform this test method" unless @supply_category_with_parent.destroy
  end
  
  def test_destroy_root_child_when_supplies_in
    self.send("create_"+@supply.class.name.tableize)
    @supply_category_root_child = @supply.class.last.send(@supply_category.class.name.underscore)
    
    assert !@supply_category_root_child.can_be_destroyed?, "it should NOT be able to be destroyed because it has supplies"
    assert !@supply_category_root_child.destroy, "it should fail at disable because it cannot be destroyed"
    
    for supply in @supply_category_root_child.send(@supply.class.name.tableize)
      flunk "supply should destroy with success to perform this test" unless supply.destroy
    end
    @supply_category_root_child.reload
    assert @supply_category_root_child.can_be_destroyed?, "it should be able to be destroyed"
    assert @supply_category_root_child.destroy, "it should destroy with success"
  end
  
  def test_destroy_root
    assert !@supply_category.can_be_destroyed?, "it should NOT be able to be destroyed because it has one children"
    assert !@supply_category.destroy, "@supply_category should NOT be destroyed because it cannot be destroyed"
    
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    assert !@supply_category.can_be_destroyed?, "it should NOT be able to be destroyed because it has one children disabled"
    assert !@supply_category.destroy, "@supply_category should NOT be destroyed because it cannot be destroyed"
    
    flunk "@supply_category_with_parent must be destroyed with success to perform this test method" unless @supply_category_with_parent.destroy
    assert @supply_category.can_be_destroyed?, "it should be able to be destroyed"
    assert @supply_category.destroy, "@supply_category should be destroyed because it can be destroyed"
  end
  
  def test_reactivate_root_child
    assert !@supply_category_with_parent.can_be_reactivated?, "it should NOT be able to be reactivated because it is still enable"
    
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    
    assert @supply_category_with_parent.can_be_reactivated?, "it should NOT be able to be reactivated"
    assert @supply_category_with_parent.reactivate, "it should reactivate with success"
    assert_equal true, @supply_category_with_parent.enable, "these two should be equal because it has been reactivated"
    assert_equal nil, @supply_category_with_parent.disabled_at, "these two should be equal because it has been reactivated"
    
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    flunk "@supply_category must be disabled with success to perform this test method" unless @supply_category.disable
    
    assert !@supply_category_with_parent.can_be_reactivated?, "it should NOT be able to be reactivated because its parent is disabled"
  end
  
  def test_reactivate_root
    assert !@supply_category.can_be_reactivated?, "it should NOT be able to be reactivated because it is still enable"
    
    flunk "@supply_category_with_parent must be disabled with success to perform this test method" unless @supply_category_with_parent.disable
    flunk "@supply_category must be disabled with success to perform this test method" unless @supply_category.disable
    
    assert @supply_category.can_be_reactivated?, "it should NOT be able to be reactivated"
    assert @supply_category.reactivate, "it should reactivate with success"
    assert_equal true, @supply_category.enable, "these two should be equal because it has been reactivated"
    assert_equal nil, @supply_category.disabled_at, "these two should be equal because it has been reactivated"
  end  
  
  def test_has_children_disable
    self.send("create_"+@supply.class.name.tableize)
    @supply_category_root_child = @supply.class.last.send(@supply_category.class.name.underscore)
    
    assert !@supply_category_root_child.has_children_disabled?, "all its children must be enabled"
    
    for supply in @supply_category_root_child.send(@supply.class.name.tableize)
      flunk "supply should destroy with success to perform this test" unless supply.disable
    end
    @supply_category_root_child.reload
    assert @supply_category_root_child.has_children_disabled?, "all its children must be disabled"
  end
  
  def test_has_children_enable
    self.send("create_"+@supply.class.name.tableize)
    @supply_category_root_child = @supply.class.last.send(@supply_category.class.name.underscore)
    
    assert @supply_category_root_child.has_children_enabled?, "all its children must be enabled"
    
    for supply in @supply_category_root_child.send(@supply.class.name.tableize)
      flunk "supply should destroy with success to perform this test" unless supply.disable
    end
    @supply_category_root_child.reload
    assert !@supply_category_root_child.has_children_enabled?, "all its children must be disabled"
  end
  
  def test_has_many_supply_categories
    assert_equal @supply_category.send(@supply.class.name.underscore+"_categories"), [@supply_category_with_parent],
      "@supply_category should have a child supply category"
  end

  def test_belongs_to_supply_category
    assert_equal @supply_category_with_parent.send(@supply.class.name.underscore+"_category"), @supply_category, "@supply_category_with_parent should have a parent"
  end  
  
  def test_stock_value
    @supply_category = @supply_category.class.new
    assert_equal 0.0, @supply_category.stock_value, "these two should be equal as this category does not own any stock"
    
    total = 0.0
    for category in self.send(@supply.class.name.underscore+"_categories",:child).send(@supply.class.name.underscore+"_category").children
      total += category.stock_value
    end    
    assert_equal total, self.send(@supply.class.name.underscore+"_categories",:child).send(@supply.class.name.underscore+"_category").stock_value, "its stock value should be equal to the total of its categories stock value"
    
    total = 0.0
    for supply in self.send(@supply.class.name.underscore+"_categories",:child).send(@supply.class.name.tableize)
      total += supply.stock_value
    end    
    assert_equal total, self.send(@supply.class.name.underscore+"_categories",:child).stock_value, "its stock value should be equal to the total of its supplies stock value"
  end
end
