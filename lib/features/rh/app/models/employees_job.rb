class EmployeesJob < ActiveRecord::Base
  belongs_to :employee
  belongs_to :job
  
  validates_presence_of :employee, :job
end
