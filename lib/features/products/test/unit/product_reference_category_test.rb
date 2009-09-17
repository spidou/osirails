require 'test/test_helper'

class ProductReferenceCategoryTest < ActiveSupport::TestCase
  fixtures :product_reference_categories

  def setup
    @product_reference_category = product_reference_categories(:parent)
    @product_reference_category_with_parent = product_reference_categories(:child)
  end

  def test_read
    assert_nothing_raised "A ProductReferenceCategory should be read" do
      ProductReferenceCategory.find_by_name(@product_reference_category.name)
    end
  end

  def test_update
    assert @product_reference_category.update_attributes(:name => 'newname'), "A ProductReferenceCategory should be update"
  end

  def test_delete
    assert_difference 'ProductReferenceCategory.count', -1 do
      @product_reference_category_with_parent.destroy
    end
  end

  def test_recursiv_delete
    assert_difference 'ProductReferenceCategory.count', -2 do
      @product_reference_category.destroy
    end
  end

  def test_presence_of_name
    assert_no_difference 'ProductReferenceCategory.count' do
      product_reference_category = ProductReferenceCategory.create
      assert_not_nil product_reference_category.errors.on(:name), "A ProductReferenceCategory should have a name"
    end
  end

  def test_parent_of_product_reference_category
    assert_equal @product_reference_category.product_reference_categories,
    [@product_reference_category_with_parent],
    "This ProductReferenceCategory should have a child"
  end

  def test_ability_to_have_a_parent
    assert !@product_reference_category.can_has_this_parent?(@product_reference_category.id), "A ProductReferenceCategory should not have himself as parent"

    assert !@product_reference_category.can_has_this_parent?(@product_reference_category_with_parent), "A ProductReferenceCategory should not have a child has parent"
  end

  def test_ability_to_delete
    assert @product_reference_category_with_parent.can_be_destroyed?, "This ProductReferenceCategory should be delete"

    assert !@product_reference_category.can_be_destroyed?, "This ProductReferenceCategory should not be delete"
  end

  def test_disabled_children
    assert !@product_reference_category.has_children_disable?, "This ProductReferenceCategory should not have disable children"

    @product_reference_category_with_parent.update_attributes(:enable => false)
    assert @product_reference_category.has_children_disable?, "This ProductReferenceCategory should have disable children"
  end
end
