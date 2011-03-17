require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceTypeTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  
  should_validate_uniqueness_of :name
  
  should_allow_values_for :factorisable, true, false
  
  should_journalize :identifier_method => :name
end
