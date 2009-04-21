require 'test_helper'

class ProductReferenceTest < ActiveSupport::TestCase
  fixtures :product_reference_categories, :product_references

  def setup
    @product_reference_category = product_reference_categories(:child)
    @product_reference = product_references(:normal)
  end

  def test_read
    assert_nothing_raised "A ProductReference should be read" do
      ProductReference.find_by_name(@product_reference.name)
    end
  end

  def test_update
    assert @product_reference.update_attributes(:name => 'newname'), "A ProductReference should be update"
  end

  def test_destroy
    assert_difference 'ProductReference.count', -1 do
      @product_reference.destroy
    end
  end

  def test_presence_of_name
    assert_no_difference 'ProductReference.count' do
      product_reference = ProductReference.create
      assert_not_nil product_reference.errors.on(:name), "A ProductReference should have a name"
    end
  end

  def test_presence_of_reference
    assert_no_difference 'ProductReference.count' do
      product_reference = ProductReference.create
      assert_not_nil product_reference.errors.on(:reference), "A ProductReference should have a reference"
    end
  end

  def test_uniqness_of_reference
    assert_no_difference 'ProductReference.count' do
      product_reference = ProductReference.create(:reference => @product_reference.reference)
      assert_not_nil product_reference.errors.on(:reference), "A ProductReference should have an uniq reference"
    end
  end

  def test_ability_to_delete
    assert @product_reference.can_be_destroyed?, "This ProductReference should be able to be delete"
  end

  def test_product_reference_category
    assert_equal @product_reference.product_reference_category, @product_reference_category, "This ProductReference should have a ProductReferenceCategory"
  end
end
