class EmployeesJob < ActiveRecord::Base
  # Relationships
  belongs_to :employee
  belongs_to :job

  # Validations
  validates_presence_of :employee_id, :job_id
end
