require 'test_helper'

class EstimateProductReferenceTest < ActiveSupport::TestCase
  def test_presence_of_estimate_id
    assert_no_difference 'EstimatesProductReference.count' do
      estimate = EstimatesProductReference.create
      assert_not_nil estimate.errors.on(:estimate_id),
        "An EstimateProductReference should have an estimate id"
    end
  end

  def test_presence_of_product_reference_id
    assert_no_difference 'EstimatesProductReference.count' do
      estimate = EstimatesProductReference.create
      assert_not_nil estimate.errors.on(:product_reference_id),
        "An EstimateProductReference should have a product reference id"
    end
  end
end
