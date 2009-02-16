class JobContract < ActiveRecord::Base
  include Permissible
  
  belongs_to :employees
  belongs_to :employee_state
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"
  
  acts_as_file

  #Callbacks
  after_create :save_salary  

  #OPTIMIZE this method should return the actual salary. but if the human resources project to rise an employee's salary for the next month, this method will return the salary for the next month, and not the actual salary. perhaps we should rename this method to "actual_salary"
  #return the most recent salary
  def salary
    self.salaries.first
  end

  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:job_contract_type] = "Type de contrat :"
  @@form_labels[:start_date] = "Date de début :"
  @@form_labels[:end_date] = "Date de fin :"
  @@form_labels[:employee_state] = "Status :"
  @@form_labels[:salary] = "Montant du salaire :"


  # this method permit to save the iban of the employee when it is passed with the employee form
  def salary_attributes=(salary_attributes)
      # verify if the salary is net or not and convert it if needed 
      if salary_attributes['type']['value'] == "Net"
        tmp = salary_attributes['salary'].to_f/0.8
        salary_attributes['salary'] = tmp
      end
    self.salaries << Salary.new(salary_attributes)
  end
  
  def save_salary
     self.salaries.save unless self.salaries==[]
  end
  
end
