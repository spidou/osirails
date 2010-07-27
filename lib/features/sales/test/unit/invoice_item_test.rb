require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceItemTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :invoice, :end_product
end
