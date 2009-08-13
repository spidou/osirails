class Checking < ActiveRecord::Base
  has_permissions :as_business_object, :additional_methods => [:super_edit]
  
  belongs_to :employee
  belongs_to :user
  
  with_options :allow_nil => true do |c|
    c.validates_numericality_of :overtime_hours, :overtime_minutes,:absence_hours, :absence_minutes
  end
  
  validates_presence_of :absence_comment,            :if => Proc.new { |o| o.mandatory_absence_comment? }
  validates_presence_of :overtime_comment,           :if => Proc.new { |o| o.mandatory_overtime_comment? }
  validates_presence_of :date
  validates_presence_of :user_id, :employee_id
  validates_presence_of :user,                       :if => :user_id
  validates_presence_of :employee,                   :if => :employee_id
  
  validate :validates_one_checking_per_day_and_per_employee
  validate :validates_restricted_edit,                             :if => :employee_id and :date
#  validate :validates_correlation_between_absence_and_other_datas, :if => :absence
  validate :validates_good_hours, :validates_good_minutes
  validate :validates_not_empty_checking
  validate :validates_date_not_too_far_away,                       :if => :date
  
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
  
  private
    
    def validates_one_checking_per_day_and_per_employee
      if new_record?
        duplicate_checkings = !Checking.all(:conditions => ["employee_id =? and date =?", employee_id, date]).empty?
        if duplicate_checkings
          errors.add(:employee_id, "invalide : cet employé a déjà un pointage aujourd'hui")
          errors.add(:date, "invalide : cet employé a déjà un pointage aujourd'hui")
        end
      end
    end
    
    def validates_restricted_edit
      unless new_record?
        if Date.today.cweek != created_at.to_date.cweek
          errors.add_to_base("Trop tard pour modifier le pointage") unless self.attributes.select {|attribute,value| value != send("#{attribute}_was")}.empty?
        else
          errors.add(:employee_id, "ne doit pas être modifié") if employee_id != employee_id_was
          errors.add(:date, "ne doit pas être modifié") if date != date_was
          errors.add(:user_id, "invalide : seul le créateur du pointage peut le modifier") if user_id != user_id_was
        end
      end
    end
    
#    def validates_correlation_between_absence_and_other_datas
#      error_message = "doit être à 0 si il y a une absence"
#      if [MORNING_ABSENCE, DAY_ABSENCE].include?(absence)      
#        errors.add(:morning_delay_hours, "#{error_message} le matin") unless morning_delay_hours.nil? or morning_delay_hours == 0
#        errors.add(:morning_overtime_hours,"#{error_message} le matin") unless morning_overtime_hours.nil?  or morning_overtime_hours == 0
#        errors.add(:morning_delay_minutes, "#{error_message} le matin") unless morning_delay_minutes.nil? or morning_delay_minutes == 0
#        errors.add(:morning_overtime_minutes,"#{error_message} le matin") unless morning_overtime_minutes.nil?  or morning_overtime_minutes == 0
#      end
#      if [AFTERNOON_ABSENCE, DAY_ABSENCE].include?(absence)
#        afternoon = "l'aprés-midi"
#        errors.add(:afternoon_delay_hours, "#{error_message} #{afternoon}") unless afternoon_delay_hours.nil? or afternoon_delay_hours == 0
#        errors.add(:afternoon_overtime_hours,"#{error_message} #{afternoon}") unless afternoon_overtime_hours.nil? or afternoon_overtime_hours == 0
#        errors.add(:afternoon_delay_minutes, "#{error_message} #{afternoon}") unless afternoon_delay_minutes.nil? or afternoon_delay_minutes == 0
#        errors.add(:afternoon_overtime_minutes,"#{error_message} #{afternoon}") unless afternoon_overtime_minutes.nil? or afternoon_overtime_minutes == 0
#      end  
#    end
    
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
      at_least_one = ![ absence_hours, absence_minutes, overtime_minutes, overtime_hours ].reject {|n|  n.nil? or n == 0}.empty?
      errors.add_to_base("un pointage doit comporter au moins une absence, heure supplémentaire ou retard") unless at_least_one
    end
    
    def validates_date_not_too_far_away
      errors.add(:date, "ne doit pas être trop éloignée de la date d'aujourd'hui") if date > Date.today+1.month or date < Date.today-1.month
    end
end
