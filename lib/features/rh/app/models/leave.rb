class Leave < ActiveRecord::Base
  include LeaveAndLeaveRequest
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  named_scope :actives, :conditions => ['cancelled =? or cancelled is null', false]
  named_scope :cancelled_leaves, :conditions => ['cancelled =?', true]
  
  attr_accessor :while_cancel
  attr_protected :while_cancel
  
  belongs_to :employee
  belongs_to :leave_type
  belongs_to :leave_request
  
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :leave_type_id
  validates_presence_of :leave_type,                :if => :leave_type_id
  validates_presence_of :employee_id
  validates_presence_of :employee,                  :if => :employee_id
  
  validates_numericality_of :duration
  
  validates_persistence_of :cancelled,              :unless => :while_cancel
  validates_persistence_of :employee_id
  validates_persistence_of :start_date, :end_date, :start_half, :end_half, :leave_type_id, :duration, :if => :cancelled
  
  validate :validates_not_cancelled_at_creation
  validate :validates_dates_consistency, :if => :start_date_and_end_date
  validate :validates_unique_dates
  
  # Method that permit to cancel a record
  # and to use validations according to the cancel needs
  # thank's to validate_cancel flag
  #
  def cancel
    self.while_cancel = true
    result = update_attributes(:cancelled => true);
    self.while_cancel = false
    result
  end
  
  def is_for_current_year?
    end_date >= Employee.leave_year_start_date and start_date <= Employee.leave_year_end_date
  end
  
  def can_be_edited?
    !cancelled_was
  end
  
  def can_be_cancelled?
    !cancelled_was
  end
  
  private
    
    def validates_not_cancelled_at_creation
      errors.add(:cancelled, "est invalide") if cancelled and new_record?
    end
    
    def validates_unique_dates
      check_unique_dates(conflicting_leaves(future_leaves)) if employee
    end
end



