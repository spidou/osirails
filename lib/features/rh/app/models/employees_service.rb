class EmployeesService < ActiveRecord::Base
  # Relationships
  belongs_to :employee
  belongs_to :service

  # Validations
  validates_presence_of :employee_id, :service_id
end
