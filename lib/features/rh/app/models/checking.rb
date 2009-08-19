class Checking < ActiveRecord::Base
  has_permissions :as_business_object, :additional_methods => [:override, :cancel]
  
  belongs_to :employee
  belongs_to :user
  
  named_scope :actives, :conditions => ["cancelled=? or cancelled is null", false]
  
  attr_accessor :validate_override, :validate_cancel
  attr_protected :validate_override, :validate_cancel
  
  validates_numericality_of :overtime_hours, :overtime_minutes, :absence_hours, :absence_minutes, :allow_nil => true
  
  validates_presence_of :absence_comment,            :if => Proc.new { |o| o.mandatory_absence_comment? }
  validates_presence_of :overtime_comment,           :if => Proc.new { |o| o.mandatory_overtime_comment? }
  validates_presence_of :date
  validates_presence_of :user_id, :employee_id
  validates_presence_of :user,                       :if => :user_id
  validates_presence_of :employee,                   :if => :employee_id
  
  validate :validates_one_checking_per_day_and_per_employee
  validate :validates_restricted_edit,                             :if => :date and :employee_id
  validate :validates_good_hours, :validates_good_minutes
  validate :validates_not_empty_checking
  validate :validates_date_not_too_far_away,                       :if => :date
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:employee]                    = "Employ&eacute; :"
  @@form_labels[:date]                        = "Date :"
  @@form_labels[:absence_hours]               = "Absence :"
  @@form_labels[:absence_comment]             = "Commentaire :"
  @@form_labels[:overtime_hours]              = "Heures supplémentaires :"
  @@form_labels[:overtime_comment]            = "Commentaire :"
  
  def mandatory_absence_comment?
    mandatory_comment?(absence_hours, absence_minutes)
  end
  
  def mandatory_overtime_comment?
    mandatory_comment?(overtime_hours, overtime_minutes)
  end
  
  def get_float_hour(h, min)
    h.to_f + min.minutes.to_f/3600
  end
  
  # Method that return true if the to arguments are not null and not equal to 0
  #
  def mandatory_comment?(hours, minutes)
    (!hours.nil? and hours != 0) or (!minutes.nil? and minutes != 0)
  end
  
  def can_be_overrided?
    Date.today.cweek != created_at.to_date.cweek
  end
  
  # Method that permit to override a record
  #
  def override
    if can_be_overrided?
      self.validate_override = true
      result = save
      self.validate_override = false
    else
      errors.add_to_base("Ce pointage ne peut pas être corrigé")
    end
    return result || false
  end
  
  # Method that permit to cancel a record
  # and to use validations according to the cancel needs
  # thank's to validate_cancel flag
  #
  def cancel
    self.validate_cancel = true
    result = update_attributes(:cancelled => true)
    self.validate_cancel = false
    result
  end
  
  private
    
    def validates_one_checking_per_day_and_per_employee
      if new_record? and employee
        duplicate_checkings = !employee.checkings.actives.all(:conditions => ["date = ?", date]).empty?
        if duplicate_checkings
          error_message = "est invalide : cet employé a déjà un pointage pour aujourd'hui"
          errors.add(:employee_id, error_message)
          errors.add(:date, error_message)
        end
      end
    end
    
    def validates_restricted_edit
      unless new_record?
        if Date.today.cweek != created_at.to_date.cweek
          errors.add_to_base("Ce pointage ne peut plus etre modifié") if !self.validate_override
        else
          verify_fixed_attributes
        end
      end
    end
    
    def verify_fixed_attributes
      errors.add(:cancelled, "ne doit pas être modifié") if cancelled != cancelled_was and !self.validate_cancel
      errors.add(:employee_id, "ne doit pas être modifié") if employee_id != employee_id_was
      errors.add(:date, "ne doit pas être modifié") if date != date_was
      errors.add(:user_id, "invalide : seul le créateur du pointage peut le modifier") if user_id != user_id_was
    end

    def validates_good_hours
      verify_times({:overtime_hours => overtime_hours, :absence_hours => absence_hours}, "ne doit pas être plus grand que 23 heures", 23)
    end
    
    def validates_good_minutes
      verify_times({:overtime_minutes => overtime_minutes, :absence_minutes => absence_minutes}, "ne doit pas être plus grand que 59 minutes", 59)
    end
    
    def verify_times(hash, message, wanted_value)
      hash.each_pair do |attribute, value|
        unless value.nil?
          errors.add(attribute, message) if value > wanted_value
        end
      end
    end
    
    def validates_not_empty_checking
      at_least_one = ![ absence_hours, absence_minutes, overtime_hours, overtime_minutes ].reject{ |n| n.nil? or n == 0 }.empty?
      unless at_least_one
        errors.add(:absence_hours, "Vous devez au moins signaler une absence")
        errors.add(:overtime_hours, "Vous devez au moins signaler des heures supplémentaires")
      end
    end
    
    def validates_date_not_too_far_away
      errors.add(:date, "ne doit pas être trop éloignée de la date d'aujourd'hui") if date > Date.today+1.month or date < Date.today-1.month
    end
end
