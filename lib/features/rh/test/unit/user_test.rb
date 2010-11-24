require File.dirname(__FILE__) + '/../rh_test'

class UserTest < ActiveSupport::TestCase
  should_have_one :employee
  
  should_have_many :checkings
  
  should_act_on_journalization_with :employee_name
  
  should_journalize :identifier_method => :employee_name
end
