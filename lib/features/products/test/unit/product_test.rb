require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'Product.count' do
      product = Product.create
      assert_not_nil product.errors.on(:name), "A Product should have a name"
    end
  end
  
  def test_presence_of_product_reference_id
    assert_no_difference 'Product.count' do
      product = Product.create
      assert_not_nil product.errors.on(:product_reference_id), "A Product should have a product reference id"
    end
  end
end