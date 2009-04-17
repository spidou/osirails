require 'test_helper'

class EmployeesServiceTest < ActiveSupport::TestCase
  def setup
    @employee_service = EmployeesService.create(:employee_id => 1, :service_id => 1)
  end
  
  def test_presence_of_employee_id
    @employee_service.update_attributes(:employee_id => nil)
    assert_not_nil @employee_service.errors.on(:employee_id), "An EmployeesService should have an employee id"
  end
  
  def test_presence_of_service_id
    @employee_service.update_attributes(:service_id => nil)
    assert_not_nil @employee_service.errors.on(:service_id), "An EmployeesService should have a service id"
  end
end
