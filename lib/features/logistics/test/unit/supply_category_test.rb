module SupplyCategoryTest  
  def test_presence_of_name
    @supply_category_without_name = @supply_category.class.send("new")
    @supply_category_without_name.valid?
    assert @supply_category_without_name.errors.on(:name), "This supply category should NOT be valid because name is nil"
    
    @supply_category_without_name.name = "Hello World"
    @supply_category_without_name.valid?
    assert !@supply_category_without_name.errors.on(:name), "This supply category  should be valid"
  end
  
  def test_delete
    assert_difference "#{@supply_category_with_parent.class}.count", -1 do
      assert @supply_category_with_parent.destroy, "@supply_category_with_parent should be deleted with success"
    end
  end

  def test_recursive_delete
    assert_difference "#{@supply_category.class}.count", -2 do
      assert @supply_category.destroy, "@supply_category and its child should be deleted with success"
    end
  end  

  def test_ability_to_delete
    assert @supply_category_with_parent.can_be_destroyed?, "@supply_category_with_parent should be deletable"
  end

  def test_unability_to_delete
    assert !@supply_category.can_be_destroyed?, "@supply_category should NOT be deletable"
  end

  def test_disabled_children
    assert !@supply_category.has_children_disable?, "@supply_category should NOT have disabled children"

    @supply_category_with_parent.update_attributes(:enable => false)
    assert @supply_category.has_children_disable?, "@supply_category should have disabled children"
  end  
end
