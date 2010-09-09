class JobContract < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :job_contract, :job_contract_endorsement, :resignation_letter, :demission_letter, :other
  
  # Relationships
  belongs_to :employee
  belongs_to :employee_state
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"

  # Validations
  #TODO active these validations once the process to create job_contract and employee_state is well determined
#  validates_presence_of :employee_state_id, :job_contract_type_id
#  validates_presence_of :employee_state,    :if => :employee_state_id
#  validates_presence_of :job_contract_type, :if => :job_contract_type_id
  
  validates_associated :salaries

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
  
  # Search Plugin
  has_search_index  :only_attributes    => [:start_date, :departure],
                    :only_relationships => [:job_contract_type]
  
  #return the actual salary
  #OPTIMIZE use 'has_one :current_salary' instead!
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
    actual_salary.save(false) if !actual_salary.nil? and actual_salary.new_record?
  end
end
