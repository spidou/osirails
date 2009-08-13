require 'test/test_helper'

class EmployeesServiceTest < ActiveSupport::TestCase
  def test_presence_of_employee_id
    assert_no_difference 'EmployeesService.count' do
      employee_service = EmployeesService.create
      assert_not_nil employee_service.errors.on(:employee_id),
        "An EmployeesService should have an employee id"
    end
  end

  def test_presence_of_service_id
    assert_no_difference 'EmployeesService.count' do
      employee_service = EmployeesService.create
      assert_not_nil employee_service.errors.on(:service_id),
        "An EmployeesService should have a service id"
    end
  end
end
