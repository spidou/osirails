class EmployeeService < ActiveRecord::Base
  belongs_to :employee
  belongs_to :service
end