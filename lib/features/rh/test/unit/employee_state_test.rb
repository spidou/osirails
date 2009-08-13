require 'test/test_helper'

class EmployeeStateTest < ActiveSupport::TestCase
  fixtures :employee_states

  def setup
    @employee_state = employee_states(:freelance)
  end

  def test_presence_of_name
    assert_no_difference 'EmployeeState.count' do
      employee_state = EmployeeState.create
      assert_not_nil employee_state.errors.on(:name), "An EmployeeState should have a name"
    end
  end

  def test_uniqness_of_name
    assert_no_difference 'EmployeeState.count' do
      employee_state = EmployeeState.create(:name => @employee_state.name)
      assert_not_nil employee_state.errors.on(:name), "An EmployeeState should have an uniq name"
    end
  end
end
