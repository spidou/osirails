class JobContract < ActiveRecord::Base
  include Permissible
  
  belongs_to :employees
  belongs_to :employee_state
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"
  
  validates_associated :salaries  

  acts_as_file

  #Callbacks
  after_update :save_salary 

  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:job_contract_type] = "Type de contrat :"
  @@form_labels[:start_date] = "Date de début :"
  @@form_labels[:end_date] = "Date de fin :"
  @@form_labels[:employee_state] = "Status :"
  @@form_labels[:gross_amount] = "Montant brut du salaire :"
  
  #return the actual salary
  def actual_salary
    self.salaries.first
  end
  
  # this method permit to save the salary of the employee when it is passed with the job_contract form
  def salary_attributes=(salary_attributes)
    salaries.build(salary_attributes) unless salary_attributes[:gross_amount].to_f == salaries.first[:gross_amount]
  end
  
  def save_salary
    self.salaries.each do |salary| 
      salary.save(false) if salary.new_record?
    end
  end

end
