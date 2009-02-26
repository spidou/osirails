class JobContract < ActiveRecord::Base
  include Permissible
  
  belongs_to :employee
  belongs_to :employee_state
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"
  
#  validates_associated :salaries  

  #acts_as_file

  #Callbacks
  after_update :save_salary 

  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:job_contract_type] = "Type de contrat :"
  @@form_labels[:start_date] = "Date de début :"
  @@form_labels[:end_date] = "Date de fin :"
  @@form_labels[:employee_state] = "Statut :"
  @@form_labels[:salary] = "Salaire brut :"
  
  #return the actual salary
  def actual_salary
    salaries.first
  end
  
  def salary
    actual_salary.nil? ? nil : actual_salary.gross_amount
  end
  
  def salary=(gross_amount)
    salaries.build(:gross_amount => gross_amount) if gross_amount.to_f != salary
  end
  
  def save_salary
    salaries.last.save(false) if !salaries.last.nil? and salaries.last.new_record?
  end
end
