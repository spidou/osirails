class Leave < ActiveRecord::Base
  
  named_scope :actives, :conditions => ['cancelled =? or cancelled is null', false]
  named_scope :cancelled_leaves, :conditions => ['cancelled =?', true]
  
  belongs_to :employee
  belongs_to :leave_type
  
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :leave_type_id
  validates_presence_of :leave_type,    :if => :leave_type_id
  validates_presence_of :employee_id
  validates_presence_of :employee,      :if => :employee_id
  
  validates_numericality_of :duration
#  validates_numericality_of :retrieval, :allow_nil => true
  
  validate :validates_is_new_record
  validate :validates_not_cancelled_at_creation
#  validate :validates_retrieval_value_is_correct,   :if => :duration
  validate :validates_date_is_correct,              :if => :start_date and :end_date
  validate :validates_not_overlay_with_other_leave, :if => :employee
  
#  validate :validates_not_extend_on_two_years, :if => :start_date and :end_date
  
  # method to permit a leave cancellation
  def cancel
    unless cancelled_was
      self.reload.update_attribute_with_validation_skipping("cancelled", true)
    else
      false
    end
  end
  
  # method to get leave duration in days(float), the period start is taken in account
  def total_estimate_duration(period_start = start_date, period_end = end_date)
    return 0 if period_start.nil? or period_end.nil?
    total = 0.0
    workable_days = ConfigurationManager.admin_society_identity_configuration_workable_days
    legal_holidays = ConfigurationManager.admin_society_identity_configuration_legal_holidays
    current = period_start
    (period_end - period_start + 1).to_i.times do
      total += 1 if workable_days.include?(current.wday.to_s) and !legal_holidays.include?("#{current.month}/#{current.day}")
      current = current.tomorrow 
    end
    total -= 0.5 if end_half and workable_days.include?(period_end.wday.to_s)
    total -= 0.5 if start_half and workable_days.include?(period_start.wday.to_s)  
    return total
  end
  
#  # method that take in account retrieval value if there's one
#  def estimate_duration
#    value = total_estimate_duration(start_date, end_date)
##    value -= retrieval unless retrieval.nil?
#    value
#  end
  
  def calendar_duration
    return 0 if start_date.nil? or end_date.nil? or (start_date > end_date)
    total = (end_date - start_date).to_i + 1
    total -= 0.5 if end_half
    total -= 0.5 if start_half
    total
  end
  
  # TODO the tests
  def is_for_current_year?
    end_date >= Employee.leave_year_start_date and start_date <= Employee.leave_year_end_date
  end
  
  private
    
    def validates_not_cancelled_at_creation
      errors.add(:cancelled, "est invalide") if cancelled and new_record?
    end
    
#    def validates_not_extend_on_two_years
#      error_message = " vous devriez créer deux congés différents"
#      l_year_start_date = Employee.leave_year_start_date
#      l_year_end_date = Employee.leave_year_end_date
#      errors.add(:start_date, "doit être plus grand ou égal à leave year end, #{error_message}") if start_date < l_year_start_date and end_date > l_year_start_date
#      errors.add(:end_date, "doit être plus petit ou égal à leave year start, #{error_message}") if end_date > l_year_end_date and start_date < l_year_end_date
#    end
#  
#    def validates_duration_is_correct
#      leave_duration_limit = ConfigurationManager.admin_society_identity_configuration_leave_duration_limit
#      if duration > leave_duration_limit
#        errors.add(:start_date, "wrong value : leave duration mustn't be higher than #{leave_duration_limit}")
#        errors.add(:end_date, "wrong value : leave duration mustn't be higher than #{leave_duration_limit}")
#      end  
#    end
#    
#    def retrieval_value_is_correct
#      unless retrieval.nil?
#        errors.add(:retrieval, "doit être plus petit à égale à #{duration}") if retrieval > duration
#      end
#    end
    
    def validates_date_is_correct
      if start_date > end_date
        errors.add(:start_date, "doit être plus petit que la date de fin") 
        errors.add(:end_date, "doit être plus grand que la date de début")
      end
      unless end_half.nil? or start_half.nil?
        if start_date == end_date and ( start_half and end_half )
          errors.add(:start_half, "ne peut pas être égal à end_half")
          errors.add(:end_half,"ne peut être égal à start_half")
        end
      end
    end
    
    def validates_not_overlay_with_other_leave
      other_leaves = employee.leaves.actives
      unless employee.nil?
        errors.add(:start_date, " est invalide, fait partie d'un autre congé") unless other_leaves.select {|n| (n.start_date..n.end_date).include?(start_date)}.empty?
        errors.add(:end_date, "est invalide, fait partie d'un autre congé") unless other_leaves.select {|n| (n.start_date..n.end_date).include?(end_date)}.empty?
      end
    end
    
    def validates_is_new_record
      errors.add_to_base("un congé ne peut être modifié") unless self.new_record?
    end
    
      
end
