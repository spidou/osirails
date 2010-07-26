require File.dirname(__FILE__) + '/../sales_test'

class ProductReferenceCategoryTest < ActiveSupport::TestCase
  should_have_many :product_references, :product_reference_categories
  should_have_many :disabled_product_references, :disabled_product_reference_categories
  should_have_many :all_product_references, :all_product_reference_categories
  
  should_belong_to :product_reference_category
  
  should_validate_presence_of :reference, :name
  
  should_not_allow_mass_assignment_of :cancelled_at
  
  def setup
    @product_reference_category = product_reference_categories(:parent)
    @product_reference_category_with_parent = product_reference_categories(:child)
  end
  subject{ @product_reference_category }

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
  
  def test_ability_to_have_a_parent
    assert !@product_reference_category.can_has_this_parent?(@product_reference_category.id), "A ProductReferenceCategory should not have himself as parent"

    assert !@product_reference_category.can_has_this_parent?(@product_reference_category_with_parent), "A ProductReferenceCategory should not have a child has parent"
  end

  def test_ability_to_delete
    assert @product_reference_category_with_parent.can_be_destroyed?, "This ProductReferenceCategory should be delete"

    assert !@product_reference_category.can_be_destroyed?, "This ProductReferenceCategory should not be delete"
  end

  def test_disabled_children
    assert !@product_reference_category.has_disabled_children?, "This ProductReferenceCategory should not have disabled children"

    flunk "product_reference_category should be disabled, but #{@product_reference_category_with_parent.inspect}" unless @product_reference_category_with_parent.disable
    assert @product_reference_category.reload.has_disabled_children?, "This ProductReferenceCategory should have disabled children"
  end
end
