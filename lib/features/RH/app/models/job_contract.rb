class JobContract < ActiveRecord::Base
  belongs_to :employees
  belongs_to :employe_state
  belongs_to :job_contract_type
  has_one :salary
end 
