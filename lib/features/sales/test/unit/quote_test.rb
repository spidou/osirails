require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class QuoteTest < ActiveSupport::TestCase
  #TODO
  def setup
    @order = create_default_order
    @signed_quote = create_signed_quote_for(@order)
    @quote = Quote.new
    @quote.valid?
  end
  
  def teardown
    @order = @signed_quote = @quote = nil
  end
  
  def test_presence_of_estimate_step
  end
  
  def test_presence_of_creator
  end
  
  def test_presence_of_bill_to_address
  end
  
  def test_presence_of_ship_to_address
  end
  
  def test_presence_of_contact
  end
  
  def test_presence_of_quotes_product_references
  end
  
  def test_validity_of_reduction
  end
  
  def test_validity_of_carriage_costs
  end
  
  def test_validity_of_discount
    @quote.discount = nil
    @quote.valid?   
    assert @quote.errors.invalid?(:discount), "discount should NOT be valid because it is nil"
    
    @quote.discount = "foo"
    @quote.valid?    
    assert @quote.errors.invalid?(:discount), "discount should NOT be valid because it is not a number"
    
    @quote.discount = 1
    @quote.valid?
    assert !@quote.errors.invalid?(:discount), "discount should be valid"    
  end
  
  def test_validity_of_account
  end
  
  def test_validity_of_validity_delay
  end
  
  def test_validity_of_validity_delay_unit
  end
  
  def test_validity_of_status
  end
  
  def test_validity_of_validated_on
  end
  
  def test_validity_of_invalidated_on
  end
  
  def test_validity_of_sended_on
  end
  
  def test_validity_of_signed_on
  end 
  
  def test_net
    assert_equal @signed_quote.net, @signed_quote.total*(1-(@signed_quote.reduction/100)), "these two should be equal"
  end
  
  def test_net_to_paid
    assert_equal @signed_quote.net_to_paid, @signed_quote.net + @signed_quote.carriage_costs + @signed_quote.summon_of_taxes - @signed_quote.discount
  end
  
  def test_account_with_taxes
    assert_equal @signed_quote.account_with_taxes, @signed_quote.account*(1+(ConfigurationManager.sales_account_tax_coefficient/100))
  end
  
  def test_tax_coefficients
    assert_equal @signed_quote.tax_coefficients, @signed_quote.quotes_product_references.collect{ |qpr| qpr.vat }.uniq
  end
  
  def test_total_for_tax
    @signed_quote.tax_coefficients.each do |coefficient|
      assert_equal @signed_quote.total_for_tax(coefficient), @signed_quote.quotes_product_references.collect{ |qpr| qpr.total if qpr.vat == coefficient}.compact.sum
    end  
  end
end
