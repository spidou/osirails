class Leave < ActiveRecord::Base
  has_permissions :as_business_object, :additional_methods => [:cancel]
  
  named_scope :actives, :conditions => ['cancelled =? or cancelled is null', false]
  named_scope :cancelled_leaves, :conditions => ['cancelled =?', true]
  
  attr_accessor :validate_cancel
  attr_protected :validate_cancel
  
  belongs_to :employee
  belongs_to :leave_type
  
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :leave_type_id
  validates_presence_of :leave_type,    :if => :leave_type_id
  validates_presence_of :employee_id
  validates_presence_of :employee,      :if => :employee_id
  
  validates_numericality_of :duration
  
  validate :validates_is_new_record,                :unless => :validate_cancel
  validate :validates_only_cancel,                  :if => :validate_cancel
  validate :validates_not_cancelled_at_creation
  validate :validates_date_is_correct,              :if => :start_date and :end_date
  validate :validates_not_overlay_with_other_leave, :if => :employee
  
  # Method that permit to cancel a record
  # and to use validations according to the cancel needs
  # thank's to validate_cancel flag
  #
  def cancel
    self.validate_cancel = true
    result = update_attributes(:cancelled => true);
    self.validate_cancel = false
    result
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
  
  def calendar_duration
    return 0 if start_date.nil? or end_date.nil? or (start_date > end_date)
    total = (end_date - start_date).to_i + 1
    total -= 0.5 if end_half
    total -= 0.5 if start_half
    total
  end
  
  def is_for_current_year?
    end_date >= Employee.leave_year_start_date and start_date <= Employee.leave_year_end_date
  end
  
  def start_datetime
    result = start_date.to_datetime
    result += 12.hours if start_half
    result
  end
  
  def end_datetime
    result = end_date.to_datetime
    result -= 12.hours if end_half
    result
  end
  
  private
    
    def validates_not_cancelled_at_creation
      errors.add(:cancelled, "est invalide") if cancelled and new_record?
    end
    
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
      leaves = employee.leaves.actives
      leaves.delete_if {|l| l.id == id} unless new_record?
      errors.add(:start_date, "est invalide, fait partie d'un autre congé") unless leaves.select {|n| (n.start_datetime..n.end_datetime).include?(start_datetime)}.empty?
      errors.add(:end_date, "est invalide, fait partie d'un autre congé") unless leaves.select {|n| (n.start_datetime..n.end_datetime).include?(end_datetime)}.empty?
    end
    
    def validates_is_new_record
      errors.add_to_base("un congé ne peut être modifié") unless self.new_record?
    end
  
    def validates_only_cancel
      attributes_without_cancelled = attributes.reject {|attribute, v| attribute == "cancelled"}
      errors.add_to_base("un congé peut uniquement être annulé") unless attributes_without_cancelled.select {|attribute, value| value != send("#{attribute}_was")}.empty?
    end
end
