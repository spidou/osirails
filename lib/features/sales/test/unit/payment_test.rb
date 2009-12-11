require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class PaymentTest < ActiveSupport::TestCase
  should_belong_to :due_date, :payment_method
  
  should_have_attached_file :attachment
  
  should_validate_presence_of :paid_on, :payment_method_id
  
  should_validate_numericality_of :amount
  
  #TODO test validates_persistence_of :payment_method_id, :amount, :paid_on, :attachment_file_name, :attachment_file_size, :attachment_content_type
end
