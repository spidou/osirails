require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class QuoteTest < ActiveSupport::TestCase
  #TODO
  def setup
    #@order = create_default_order
    #
    #@quote = Quote.new
    #@quote.valid?
  end
  
  def teardown
    #@order = @quote = nil
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
  
  
  
end
