class EmployeeJob < ActiveRecord::Base
  belongs_to :job
  belongs_to :employee
end
