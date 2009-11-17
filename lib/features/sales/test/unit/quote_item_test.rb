require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class QuoteItemTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :quote, :product
  
  should_validate_numericality_of :unit_price, :discount, :vat, :quantity
end
