require 'estimate_duration'

class Leave < ActiveRecord::Base
  include EstimateDuration
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
  validate :validates_date_is_correct,              :if => :start_date and :end_date
  validate :validates_not_overlay_with_other_leave, :if => :employee
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:start_date] = "Date de début :"
  @@form_labels[:end_date]   = "Date de fin :"
  @@form_labels[:duration]   = "Durée :"
  @@form_labels[:leave_type] = "Type :"
  
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
end
