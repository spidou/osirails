require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class DueDateTest < ActiveSupport::TestCase
  #TODO test has_permissions, :additional_class_methods => [ :pay ]
  
  should_belong_to :invoice
  
  should_have_many :payments
  
  should_validate_presence_of :date
  should_validate_numericality_of :net_to_paid
  
  #TODO test validates_persistence_of :date, :net_to_paid
end
