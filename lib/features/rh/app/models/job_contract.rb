class JobContract < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :job_contract, :job_contract_endorsement, :resignation_letter, :demission_letter, :other
  
  belongs_to :employee
  belongs_to :job_contract_type
  
  has_many :salaries, :order => "created_at DESC"
  has_one :actual_salary, :class_name => "Salary", :order => "created_at DESC"
  
  #TODO active these validations once the process to create job_contract and employee_state is well determined
#  validates_presence_of :employee_state_id, :job_contract_type_id
#  validates_presence_of :employee_state,    :if => :employee_state_id
#  validates_presence_of :job_contract_type, :if => :job_contract_type_id
  
  validates_presence_of :start_date
  validates_presence_of :job_contract_type_id, :employee_id
  validates_presence_of :job_contract_type, :if => :job_contract_type_id
  validates_presence_of :employee, :if => :employee_id
  
  with_options :if => :end_date do |v|
    v.validates_date :start_date, :before => Proc.new {|n| n.end_date }
    v.validates_date :end_date,   :after  => Proc.new {|n| n.start_date }
  end
  
  validate :end_date_is_nil_if_job_contract_type_is_not_limited, :if => :job_contract_type
  validate :no_another_active_unlimited_contract, :if => :new_record?
  validate :dates_not_overlap, :if => Proc.new{|n| !n.another_unlimited_and_active? && n.start_date && n.employee_id}
  
  with_options :if => :departure do |v|
    v.validates_date        :departure, :on_or_after  => Proc.new {|n| n.start_date }
    v.validates_presence_of :departure_description
  end
  
  validates_associated :salaries
  
  journalize :attributes => [:job_contract_type_id, :start_date, :end_date, :departure ],
             :subresources => [:salaries]

  has_search_index  :only_attributes    => [:start_date, :end_date, :departure],
                    :additional_attributes => {:active? => :boolean},
                    :only_relationships => [:job_contract_type]
  
  after_update :save_salary 
  
  
  #return the actual salary
  #OPTIMIZE use 'has_one :current_salary' instead!
#  def actual_salary
#    salaries.first
#  end
  
  #TODO test
  def active?
    today = Date.today
    return false if self.new_record?
    (self.departure.nil? ? true : self.departure > Date.today) && self.start_date <= today && (self.end_date ? self.end_date >= today : true)
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
  
  #TODO tests
  def another_unlimited_and_active?
    JobContract.all(
      :include    => :job_contract_type,
      :conditions => ["employee_id = ? and job_contract_types.limited = ? and departure IS NULL", self.employee_id, false]
    ).any?
  end
  
  #TODO tests
  def other_job_contracts
    return nil unless self.employee_id
    JobContract.all(:conditions => ["employee_id = ? and id != ?", self.employee_id, self.id])
  end
  
  private
    
    # TODO i18n
    def end_date_is_nil_if_job_contract_type_is_not_limited
      errors.add(:end_date, "should not be set") unless self.end_date.nil? || self.job_contract_type.limited
    end
    
    #TODO tests
    def no_another_active_unlimited_contract
      errors.add_to_base("Can't create a new job contract while an unlimited one is active") if another_unlimited_and_active?
    end
    
    #TODO tests
    def dates_not_overlap
      overlap = other_job_contracts.reject do |jc|
        other_end_date = jc.departure || jc.end_date
        (other_end_date ? other_end_date <= self.start_date : false) || (self.end_date ? self.end_date <= jc.start_date : false)
      end
      
      if overlap.any?
        errors.add(:start_date, "should not overlap with another job_contract")
        errors.add(:end_date, "should not overlap with another job_contract")
      end
    end
end
