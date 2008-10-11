class JobContract < ActiveRecord::Base
  include Permissible
  
  belongs_to :employees
  belongs_to :employee_state
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"
  
  acts_as_file
  
  #OPTIMIZE this method should return the actual salary. but if the human resources project to rise an employee's salary for the next month, this method will return the salary for the next month, and not the actual salary. perhaps we should rename this method to "actual_salary"
  #return the most recent salary
  def salary
    self.salaries.first
  end
  
end