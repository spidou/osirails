class EmployeeState < ActiveRecord::Base
  has_one :job_contract
  
  validates_presence_of   :name
  validates_uniqueness_of :name
end
