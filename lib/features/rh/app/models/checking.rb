class Checking < ActiveRecord::Base
  MORNING_ABSENCE   = 1
  AFTERNOON_ABSENCE = 2
  DAY_ABSENCE       = 3
  
  belongs_to :employee
  belongs_to :user
  
  with_options :allow_nil => true do |c|
    c.validates_numericality_of :morning_overtime_hours, :morning_overtime_minutes, :morning_delay_hours, :morning_delay_minutes
    c.validates_numericality_of :afternoon_overtime_hours, :afternoon_overtime_minutes, :afternoon_delay_hours, :afternoon_delay_minutes
    c.validates_numericality_of :absence
  end
  
  validates_presence_of :absence_comment, :if => Proc.new { |o| o.mandatory_absence_comment? }
  validates_presence_of :morning_overtime_comment, :if => Proc.new { |o| o.mandatory_morning_overtime_comment? }
  validates_presence_of :morning_delay_comment, :if => Proc.new { |o| o.mandatory_morning_delay_comment? }
  validates_presence_of :afternoon_overtime_comment, :if => Proc.new { |o| o.mandatory_afternoon_overtime_comment? }
  validates_presence_of :afternoon_delay_comment, :if => Proc.new { |o| o.mandatory_afternoon_delay_comment? }
  validates_presence_of :date
  validates_presence_of :user_id, :employee_id
  validates_presence_of :user, :if => :user_id
  validates_presence_of :employee, :if => :employee_id
  
  validate :one_checking_per_day_and_per_employee
  validate :restricted_edit, :if => :employee_id and :date
  validate :correlation_between_absence_and_other_datas, :if => :absence
  validate :good_hours, :good_minutes
  
  validates_inclusion_of :absence, :in => [ nil, MORNING_ABSENCE, AFTERNOON_ABSENCE, DAY_ABSENCE ]
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:employee]                    = "Employ&eacute; :"
  @@form_labels[:date]                        = "Date :"
  @@form_labels[:absence]                     = "Signaler une absence :"
  @@form_labels[:absence_comment]             = "Commentaire :"
  @@form_labels[:morning_overtime_hours]      = "Heures suppl&eacute;mentaires :"
  @@form_labels[:afternoon_overtime_hours]    = "Heures suppl&eacute;mentaires :"
  @@form_labels[:morning_overtime_comment]    = "Commentaire :"
  @@form_labels[:afternoon_overtime_comment]  = "Commentaire :"
  @@form_labels[:morning_delay_hours]         = "Retard :"
  @@form_labels[:afternoon_delay_hours]       = "Retard :"
  @@form_labels[:morning_delay_comment]       = "Commentaire :"
  @@form_labels[:afternoon_delay_comment]     = "Commentaire :"
  
  def mandatory_absence_comment?
    mandatory_comment?(absence)
  end
  
  def mandatory_morning_overtime_comment?
    mandatory_comment?(morning_overtime_hours, morning_overtime_minutes)
  end
  
  def mandatory_morning_delay_comment?
    mandatory_comment?(morning_delay_hours, morning_delay_minutes)
  end
  
  def mandatory_afternoon_overtime_comment?
    mandatory_comment?(afternoon_overtime_hours, afternoon_overtime_minutes)
  end
  
  def mandatory_afternoon_delay_comment?
    mandatory_comment?(afternoon_delay_hours, afternoon_delay_minutes)
  end
  
  def get_float_hour(h, min)
    h.to_f + min.minutes.to_f/3600
  end
  
  private
    
    # Method that return true if the to arguments are not null and not equal to 0
    #
    def mandatory_comment?(hours, minutes = nil)
      (!hours.nil? and hours != 0) or (!minutes.nil? and minutes != 0)
    end
    
    def one_checking_per_day_and_per_employee
      if new_record?
        duplicate_checkings = !Checking.all(:conditions => ["employee_id =? and date =?", employee_id, date]).empty?
        if duplicate_checkings
          errors.add(:employee_id, ": cet employ&eacute;e a d&eacute;j&agrave; un pointage aujourd&apos;hui")
          errors.add(:date, ": cet employ&eacute;e a d&eacute;j&agrave; un pointage aujourd&apos;hui")
        end
      end
    end
    
    def restricted_edit
      unless new_record?
        errors.add(:employee_id, "ne doit pas &ecirc;tre modifi&eacute;") if employee_id != employee_id_was
        errors.add(:date, "ne doit pas &ecirc;tre modifi&eacute;") if date != date_was
      end
    end
    
    def correlation_between_absence_and_other_datas
      error_message = "doit &ecirc;tre à 0 si il y a une absence"
      if [MORNING_ABSENCE, DAY_ABSENCE].include?(absence)      
        errors.add(:morning_delay_hours, "#{error_message} le matin") unless morning_delay_hours.nil? or morning_delay_hours == 0
        errors.add(:morning_overtime_hours,"#{error_message} le matin") unless morning_overtime_hours.nil?  or morning_overtime_hours == 0
        errors.add(:morning_delay_minutes, "#{error_message} le matin") unless morning_delay_minutes.nil? or morning_delay_minutes == 0
        errors.add(:morning_overtime_minutes,"#{error_message} le matin") unless morning_overtime_minutes.nil?  or morning_overtime_minutes == 0
      end
      if [AFTERNOON_ABSENCE, DAY_ABSENCE].include?(absence)
        afternoon = "l&apos;apr&eacute;s-midi"
        errors.add(:afternoon_delay_hours, "#{error_message} #{afternoon}") unless afternoon_delay_hours.nil? or afternoon_delay_hours == 0
        errors.add(:afternoon_overtime_hours,"#{error_message} #{afternoon}") unless afternoon_overtime_hours.nil? or afternoon_overtime_hours == 0
        errors.add(:afternoon_delay_minutes, "#{error_message} #{afternoon}") unless afternoon_delay_minutes.nil? or afternoon_delay_minutes == 0
        errors.add(:afternoon_overtime_minutes,"#{error_message} #{afternoon}") unless afternoon_overtime_minutes.nil? or afternoon_overtime_minutes == 0
      end  
    end
    
    def good_hours
      verify_times({:morning_overtime_hours => morning_overtime_hours,
                    :morning_delay_hours => morning_delay_hours,
                    :afternoon_overtime_hours => afternoon_overtime_hours,
                    :afternoon_delay_hours => afternoon_delay_hours},
                    "ne doit pas &ecirc;tre plus grand que 23 heures",
                    23)
    end
    
    def good_minutes
      verify_times({:morning_overtime_minutes => morning_overtime_minutes,
                    :morning_delay_minutes => morning_delay_minutes,
                    :afternoon_overtime_minutes => afternoon_overtime_minutes,
                    :afternoon_delay_minutes => afternoon_delay_minutes},
                    "ne doit pas &ecirc;tre plus grand que 59 minutes",
                    59)
    end
    
    def verify_times(hash, message, wanted_value)
      hash.each_pair do |attribute, value|
        unless value.nil?
          errors.add(attribute, message) if value > wanted_value
        end
      end
    end
    
end
