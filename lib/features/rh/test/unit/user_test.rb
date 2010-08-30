require File.dirname(__FILE__) + '/../rh_test'

class UserTest < ActiveSupport::TestCase
  should_act_on_journalization_with :employee_name
end
