class SalariesController < ApplicationController

# GET /employees/1/index  
  def index
    params[:employee_id].nil? ? @employee = current_user.employee.id : @employee = params[:employee_id]
    @salaries = Employee.find(@employee).job_contract.salaries
  end
  
end
