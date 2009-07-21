require 'test_helper'

class QuoteTest < ActiveSupport::TestCase
  def test_numericality_of_reduction
    assert_no_difference 'Quote.count' do
      quote = Quote.create(:reduction => 'a')
      assert_not_nil quote.errors.on(:reduction),
        "An quote should have a numeric value of reduction"
    end
  end

  def test_numericality_of_carriage_costs
    assert_no_difference 'Quote.count' do
      quote = Quote.create(:carriage_costs => 'a')
      assert_not_nil quote.errors.on(:carriage_costs),
        "An quote should have a numeric value of carriage costs"
    end
  end

  def test_numericality_of_account
    assert_no_difference 'Quote.count' do
      quote = Quote.create(:account => 'a')
      assert_not_nil quote.errors.on(:account),
        "An quote should have a numeric value of account"
    end
  end

  def test_presence_of_estimate_step_id
    assert_no_difference 'Quote.count' do
      quote = Quote.create
      assert_not_nil quote.errors.on(:estimate_step_id),
        "An quote should have a estimate_step_id"
    end
  end
end
