class JobContract < ActiveRecord::Base
  belongs_to :employees
  belongs_to :employee_state
  belongs_to :job_contract_type
  has_many :salaries
  
  acts_as_file
end 
