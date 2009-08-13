require 'estimate_duration.rb'
class LeaveRequest < ActiveRecord::Base
  include EstimateDuration
  has_permissions :as_business_object, :additional_methods => [:submit, :check, :notice, :close, :cancel]
  
  # Callbacks
  
  def before_save
    if self.closed?
      self.create_leave
    end
  end
    
  # Accessors
  
  cattr_accessor :form_labels
  
  @@form_labels = Hash.new
  @@form_labels[:status] = "STATUT:"
  @@form_labels[:employee] = "Employé:"
  @@form_labels[:created_at] = "Date de la demande:"
  @@form_labels[:period] = "Période demandée:"
  @@form_labels[:start_date] = "Du:"
  @@form_labels[:end_date] = "Au:"
  @@form_labels[:start_half] = "Après-midi (inclus):"
  @@form_labels[:end_half] = "Matin (inclus):"  
  @@form_labels[:leave_type] = "Type du congé:"
  @@form_labels[:comment] = "Commentaire:"
  @@form_labels[:responsible_agreement] = "Réponse du responsable:"
  @@form_labels[:checked_at] = "Date:"
  @@form_labels[:responsible] = "Nom du responsable:"
  @@form_labels[:responsible_remarks] = "Commentaire:"
  @@form_labels[:acquired_leaves_days] = "Etat des congés payés acquis:"
  @@form_labels[:retrieval] = "Report sur l'année N-1:"
  @@form_labels[:duration] = "Durée effective totale:"
  @@form_labels[:observer_remarks] = "Observations:"
  @@form_labels[:observer] = "Notifié par:"
  @@form_labels[:noticed_at] = "Date:"
  @@form_labels[:director] = "Clôturé par:"
  @@form_labels[:director_agreement] = "Réponse de la direction:"
  @@form_labels[:agreement_true] = "ACCORD:"
  @@form_labels[:agreement_false] = "REFUS"
  @@form_labels[:director_remarks] = "Commentaire:"
  @@form_labels[:ended_at] = "Date:"  
  @@form_labels[:cancelled_at] = "Annulée le:" 
  
  # Relationships
  
  has_one :leave

  belongs_to :employee
  belongs_to :responsible, :class_name => "Employee", :foreign_key => "responsible_id"
  belongs_to :observer, :class_name => "Employee", :foreign_key => "observer_id"
  belongs_to :director, :class_name => "Employee", :foreign_key => "director_id"
  belongs_to :leave_type

  # Constants
  
  LEAVE_REQUESTS_PER_PAGE = 15
  
  STATUS_CANCELLED = 0
  STATUS_SUBMITTED = 1
  STATUS_CHECKED = 2
  STATUS_REFUSED_BY_RESPONSIBLE = -2
  STATUS_NOTICED = 3
  STATUS_CLOSED = 4
  STATUS_REFUSED_BY_DIRECTOR = -4
  
  # Time configuration
  
  Time.zone = ConfigurationManager.admin_society_identity_configuration_time_zone
  
  # Validates
  ##TODO Dates validations
  
  with_options :if => :was_unstarted? do |t|
    t.validates_presence_of :employee_id, :start_date, :end_date, :leave_type_id
    t.validates_presence_of :employee, :if => :employee_id
    t.validates_presence_of :leave_type, :if => :leave_type_id
    t.validate :validates_dates_coherence_order
    t.validate :validates_dates_coherence_validity
    t.validate :validates_same_dates_and_a_half_max
    t.validate :validates_unique_dates
  end

  with_options :if => :was_submitted_or_refused_by_responsible? do |t|
    t.validates_presence_of :responsible_id, :checked_at
    t.validates_presence_of :responsible, :if => :responsible_id
    t.validate :validates_dates_validity
  end

  with_options :if => :was_checked? do |t|
    t.validates_presence_of :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days, :duration
    t.validates_presence_of :observer, :if => :observer_id
    t.validate :validates_dates_validity
    t.validate :validates_retrieval_is_correct
  end 

  with_options :if => :was_noticed_or_refused_by_director? do |t|
    t.validates_presence_of :director_id, :ended_at
    t.validates_presence_of :director, :if => :director_id
    t.validate :validates_dates_validity
  end
  
  validates_presence_of :responsible_remarks, :if => :validates_responsible_remarks
  validates_presence_of :director_remarks, :if => :validates_director_remarks
  
  validates_persistence_of :employee, :employee_id, :start_date, :end_date, :leave_type_id, :start_half, :end_half, :comment, :if => :higher_than_step_submit?
  validates_persistence_of :responsible, :responsible_id, :checked_at, :responsible_agreement, :responsible_remarks, :if => :higher_than_step_check?
  validates_persistence_of :observer, :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days, :retrieval, :duration, :if => :higher_than_step_notice?
  
  validates_associated :leave, :if => :closed?
  
  # Validates methods

  def validates_dates_coherence_order
    if self.start_date != nil and self.end_date != nil
      errors.add(:end_date, "ne peut être antérieure à la date de début !") if self.start_date > self.end_date
    end
  end
  
  def validates_dates_coherence_validity
    if self.start_date != nil
      errors.add(:start_date, "ne peut être antérieure ou égale à aujourd'hui !") if self.start_date <= Date.today
    end
  end
  
  def validates_same_dates_and_a_half_max
    if self.start_date != nil and self.end_date != nil
      errors.add(:end_half, "ne peut être sélectionné en même temps que start half pour deux dates semblables !") if (self.start_date == self.end_date and self.start_half and self.end_half)
    end
  end

  def validates_dates_validity
    if self.start_date != nil
      errors.add(:start_date, "a expiré, veuillez annuler la demande") if self.start_date < Date.today
    end
  end
  
  def validates_retrieval_is_correct
    unless (self.retrieval.nil? or self.duration.nil?)
      errors.add(:retrieval, "doit être inférieur ou égal à #{duration} jours") if self.retrieval > self.duration
    end
  end
  
  def validates_unique_dates
    
    @self_start_datetime = start_or_end_datetime(self.start_date,self.start_half,true)
    @self_end_datetime = start_or_end_datetime(self.end_date,self.end_half,false)
  
    in_progress_leave_requests_conflicts = []
    leaves_conflicts = []
    
    if (!self.start_date.nil? and !self.end_date.nil?) 
      for element in self.employee.in_progress_leave_requests  
        if (start_or_end_datetime(element.start_date,element.start_half,true).between?(@self_start_datetime,@self_end_datetime) or start_or_end_datetime(element.end_date,element.end_half,false).between?(@self_start_datetime,@self_end_datetime))
          in_progress_leave_requests_conflicts << element
        end
      end
      
      for element in self.employee.future_leaves
        if (start_or_end_datetime(element.start_date,element.start_half,true).between?(@self_start_datetime,@self_end_datetime) or start_or_end_datetime(element.end_date,element.end_half,false).between?(@self_start_datetime,@self_end_datetime))
          leaves_conflicts << element
        end
      end
    end

    if (!in_progress_leave_requests_conflicts.nil? and !leaves_conflicts.nil?)
      if (in_progress_leave_requests_conflicts.size > 0 or leaves_conflicts.size > 0)
        error_message = "et/ou end date demandé(s) invalide(s) !<br />"
        if in_progress_leave_requests_conflicts.size > 0
          error_message += "Congés en cours de demande pour la période : <br />"
          for element in in_progress_leave_requests_conflicts
             error_message += ("- Du #{element.start_date.strftime("%d %B %Y")} au #{element.end_date.strftime("%d %B %Y")}<br />")    
          end
        end
        if leaves_conflicts.size > 0  
          error_message += "Congés déjà acceptés pour la période :<br />"
          for element in leaves_conflicts
             error_message += "- Du #{element.start_date.strftime("%d %B %Y")} au #{element.end_date.strftime("%d %B %Y")}<br />"
          end
        end
        errors.add(:start_date, error_message)
      end
    end
    
  end
  
  def validates_responsible_remarks
    !self.responsible_agreement == true and self.was_submitted_or_refused_by_responsible?
  end

  def validates_director_remarks
    !self.director_agreement == true and self.was_noticed_or_refused_by_director?
  end


  # Methods
  
  def start_or_end_datetime(date, half, is_start)
    unless date.nil?
      if half
        if is_start
          date.to_datetime + 13.hours
        else
          date.to_datetime + 12.hours
        end
      else
        if is_start
          date.to_datetime + 8.hours
        else
          date.to_datetime + 17.hours
        end
      end
    end
  end

  def can_be_submitted?
    self.was_unstarted?
  end

  def can_be_checked?
    self.was_submitted_or_refused_by_responsible?
  end

  def can_be_noticed?
    self.was_checked?
  end

  def can_be_closed?
    self.was_noticed_or_refused_by_director?
  end
  
  def can_be_created?
    self.closed?
  end

  def can_be_cancelled?
    ![nil,STATUS_CANCELLED,STATUS_CLOSED].include?(self.status)
  end
  
  def submit
    if can_be_submitted?
      self.status = STATUS_SUBMITTED
      self.save
    end
  end
  
  def check
    if can_be_checked?
      if self.responsible_agreement
        self.status = STATUS_CHECKED 
      else
        self.status = STATUS_REFUSED_BY_RESPONSIBLE
      end
      self.save
    end
  end

  def notice
    if can_be_noticed?
      self.status = STATUS_NOTICED 
      self.save 
    end
  end
  
  def close 
    if can_be_closed?
      if self.director_agreement
        self.status = STATUS_CLOSED   
      else
        self.status = STATUS_REFUSED_BY_DIRECTOR
      end
      self.save
    end
  end

  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED  
      self.save
    end
  end
  
  def create_leave
    if can_be_created?
      self.leave = build_leave({:leave_request_id => self.id, :employee_id => self.employee_id, :start_date => self.start_date, :end_date => self.end_date, :start_half => self.start_half, :end_half => self.end_half, :retrieval => self.retrieval, :leave_type_id => self.leave_type_id, :duration => self.duration})
    end  
  end
  
  def unstarted?
    self.status.nil?
  end
  
  def cancelled?
    self.status == STATUS_CANCELLED
  end
  
  def submitted?
    self.status == STATUS_SUBMITTED
  end
  
  def checked?
    self.status == STATUS_CHECKED
  end
  
  def refused_by_responsible?
    self.status == STATUS_REFUSED_BY_RESPONSIBLE
  end
  
  def noticed?
    self.status == STATUS_NOTICED
  end
  
  def closed?
    self.status == STATUS_CLOSED
  end
  
  def refused_by_director?
    self.status == STATUS_REFUSED_BY_DIRECTOR
  end
  
  def submitted_or_refused_by_responsible?
    self.submitted? or self.refused_by_responsible?
  end
  
  def noticed_or_refused_by_director?
    self.noticed? or self.refused_by_director?
  end
  
  def was_unstarted?
    self.status_was.nil?
  end
  
  def was_cancelled?
    self.status_was == STATUS_CANCELLED
  end
  
  def was_submitted?
    self.status_was == STATUS_SUBMITTED and !self.cancelled?
  end
  
  def was_checked?
    self.status_was == STATUS_CHECKED and !self.cancelled?
  end
  
  def was_refused_by_responsible?
    self.status_was == STATUS_REFUSED_BY_RESPONSIBLE and !self.cancelled?
  end
  
  def was_noticed?
    self.status_was == STATUS_NOTICED and !self.cancelled?
  end
  
  def was_closed?
    self.status_was == STATUS_CLOSED and !self.cancelled?
  end
  
  def was_refused_by_director?
    self.status_was == STATUS_REFUSED_BY_DIRECTOR and !self.cancelled?
  end
  
  def was_submitted_or_refused_by_responsible?
    self.was_submitted? or self.was_refused_by_responsible?
  end
  
  def was_noticed_or_refused_by_director?
    self.was_noticed? or self.was_refused_by_director?
  end
  
  def higher_than_step_submit?
    self.checked? or self.refused_by_responsible? or self.noticed? or self.closed? or self.refused_by_director?
  end

  def higher_than_step_check?
    self.noticed? or self.closed? or self.refused_by_director?
  end

  def higher_than_step_notice?
    self.closed? or self.refused_by_director?
  end
  
  def was_higher_than_step_unstarted?
    self.was_submitted? or self.was_checked? or self.was_refused_by_responsible? or self.was_noticed? or self.was_closed? or self.was_refused_by_director?
  end
  
  def was_higher_than_step_submit?
    self.was_checked? or self.was_refused_by_responsible? or self.was_noticed? or self.was_closed? or self.was_refused_by_director?
  end

  def was_higher_than_step_check?
    self.was_noticed? or self.was_closed? or self.was_refused_by_director?
  end

  def was_higher_than_step_notice?
    self.was_closed? or self.was_refused_by_director?
  end
  
end
