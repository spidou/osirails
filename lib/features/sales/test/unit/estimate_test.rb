require 'test_helper'

class EstimateTest < ActiveSupport::TestCase
  def test_numericality_of_reduction
    assert_no_difference 'Estimate.count' do
      estimate = Estimate.create(:reduction => 'a')
      assert_not_nil estimate.errors.on(:reduction),
        "An Estimate should have a numeric value of reduction"
    end
  end

  def test_numericality_of_carriage_costs
    assert_no_difference 'Estimate.count' do
      estimate = Estimate.create(:carriage_costs => 'a')
      assert_not_nil estimate.errors.on(:carriage_costs),
        "An Estimate should have a numeric value of carriage costs"
    end
  end

  def test_numericality_of_account
    assert_no_difference 'Estimate.count' do
      estimate = Estimate.create(:account => 'a')
      assert_not_nil estimate.errors.on(:account),
        "An Estimate should have a numeric value of account"
    end
  end

  def test_presence_of_step_estimate_id
    assert_no_difference 'Estimate.count' do
      estimate = Estimate.create
      assert_not_nil estimate.errors.on(:step_estimate_id),
        "An Estimate should have a step estimate id"
    end
  end
end
