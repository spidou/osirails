require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceItemTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :invoice, :product
end
