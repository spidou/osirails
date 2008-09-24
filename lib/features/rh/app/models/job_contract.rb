class JobContract < ActiveRecord::Base
  include Permissible
  
  belongs_to :employees
  belongs_to :employee_state
  belongs_to :job_contract_type
  has_many :salaries
  
  acts_as_file
  
  def salary
    return self.salaries.first 
  end
  
end 
