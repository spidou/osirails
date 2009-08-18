require 'estimate_duration'

class Leave < ActiveRecord::Base
  include EstimateDuration
  
  named_scope :actives, :conditions => ['cancelled =? or cancelled is null', false]
  named_scope :cancelled_leaves, :conditions => ['cancelled =?', true]
  
  belongs_to :employee
  belongs_to :leave_type
  belongs_to :leave_request
  
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :leave_type_id
  validates_presence_of :leave_type, :if => :leave_type_id
  validates_presence_of :employee_id
  validates_presence_of :employee, :if => :employee_id
  validates_presence_of :leave_request_id
  validates_presence_of :leave_request, :if => :leave_request_id
      
  validates_numericality_of :duration
  validates_numericality_of :retrieval, :allow_nil => true
  
  validate :is_new_record
  validate :not_cancelled_at_creation
  validate :retrieval_value_is_correct, :if => :duration
  validate :date_is_correct, :if => :start_date and :end_date
  validate :not_extend_on_two_years, :if => :start_date and :end_date
  
  # method to permit a leave cancellation
  def cancel
    unless cancelled_was
      self.reload.update_attribute_with_validation_skipping("cancelled", true)
    else
      false
    end
  end
  
  def calendar_duration
    return 0 if start_date.nil? or end_date.nil? or (start_date > end_date)
    total = (end_date - start_date).to_i + 1
    total -= 0.5 if end_half
    total -= 0.5 if start_half
    total
  end
  
  private
    
    def not_cancelled_at_creation
      errors.add(:cancelled, "est invalide") if cancelled and new_record?
    end
    
    def not_extend_on_two_years
      error_message = " vous devriez créer deux congés différents"
      leave_year_start_date = Employee.get_leave_year_start_date
      leave_year_end_date = leave_year_start_date + 1.year - 1.day
      errors.add(:start_date, "doit être plus grand ou égal à leave year end, #{error_message}") if start_date < leave_year_start_date and end_date > leave_year_start_date
      errors.add(:end_date, "doit être plus petit ou égal à leave year start, #{error_message}") if end_date > leave_year_end_date and start_date < leave_year_end_date
    end
    
#    def duration_is_correct
#      leave_duration_limit = ConfigurationManager.admin_society_identity_configuration_leave_duration_limit
#      if duration > leave_duration_limit
#        errors.add(:start_date, "wrong value : leave duration mustn't be higher than #{leave_duration_limit}")
#        errors.add(:end_date, "wrong value : leave duration mustn't be higher than #{leave_duration_limit}")
#      end  
#    end
    
    def retrieval_value_is_correct
      unless retrieval.nil?
        errors.add(:retrieval, "doit &ecirc;tre plus petit que #{duration}") if retrieval > duration
      end
    end
    
    def date_is_correct
      if start_date > end_date
        errors.add(:start_date, "doit &ecirc;tre plus petit que la date de fin") 
        errors.add(:end_date, "doit &ecirc;tre plus grand que la date de d&eacute;but")
      end
      unless end_half.nil? or start_half.nil?
        if start_date == end_date and ( start_half and end_half )
          errors.add(:start_half, "ne peut pas &ecirc;tre &eacute;gal &agrave; end_half")
          errors.add(:end_half,"ne peut &ecirc;tre &eacute;gal &agrave; start_half")
        end
      end
    end
    
    def is_new_record
      errors.add_to_base("un cong&eacute; ne peut &ecirc;tre modifi&eacute;") unless self.new_record?
    end
      
end
