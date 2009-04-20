class EmployeeState < ActiveRecord::Base
  # Relationships
  has_one :job_contract

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
end
 