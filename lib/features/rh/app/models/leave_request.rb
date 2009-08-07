class LeaveRequest < ActiveRecord::Base
  has_permissions :as_business_object, :additional_methods => [:submit, :check, :notice, :close, :cancel]

  # Callbacks
  
  def before_update
    if [STATUS_REFUSED_BY_RESPONSIBLE,STATUS_SUBMITTED].include?(self.status_was)
      self.check
    end
    if [STATUS_CHECKED].include?(self.status_was)
      self.notice
    end
    if [STATUS_REFUSED_BY_DIRECTOR,STATUS_NOTICED].include?(self.status_was)
      self.close
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
  @@form_labels[:leave_type] = "Type de congé:"
  @@form_labels[:comment] = "Commentaire:"
  @@form_labels[:responsible_agreement] = "Réponse du responsable:"
  @@form_labels[:checked_at] = "Date:"
  @@form_labels[:responsible] = "Nom du responsable:"
  @@form_labels[:responsible_remarks] = "Commentaire:"
  @@form_labels[:acquired_leaves_days] = "Etat des congés payés acquis:"
  @@form_labels[:observer_remarks] = "Observations:"
  @@form_labels[:observer] = "Notifié par:"
  @@form_labels[:noticed_at] = "Date:"
  @@form_labels[:director] = "Clôturé par:"
  @@form_labels[:director_agreement] = "Réponse de la direction:"
  @@form_labels[:director_remarks] = "Commentaire:"
  @@form_labels[:ended_at] = "Date:"  

  # Relationships

  belongs_to :employee
  belongs_to :responsible, :class_name => "Employee", :foreign_key => "responsible_id"
  belongs_to :observer, :class_name => "Employee", :foreign_key => "observer_id"
  belongs_to :director, :class_name => "Employee", :foreign_key => "director_id"

  # Constants
  
  STATUS_CANCELLED = 0
  STATUS_SUBMITTED = 1
  STATUS_CHECKED = 2
  STATUS_REFUSED_BY_RESPONSIBLE = -2
  STATUS_NOTICED = 3
  STATUS_CLOSED = 4
  STATUS_REFUSED_BY_DIRECTOR = -4
  
  # Validates
  ##TODO Dates validations
  
  with_options :if => :was_unstarted? do |t|
    t.validates_presence_of :employee_id, :start_date, :end_date, :leave_type_id
    t.validates_presence_of :employee, :if => :employee_id
    t.validate :dates_coherence_order
    t.validate :dates_coherence_validity
    t.validate :same_dates_and_a_half_max
  end

  with_options :if => :was_submitted_or_refused_by_responsible? do |t|
    t.validates_presence_of :responsible_id, :checked_at
    t.validates_presence_of :responsible, :if => :responsible_id
    t.validate :dates_validity
    t.validates_presence_of :responsible_remarks, :if => :responsible_agreement_is_false?
  end

  with_options :if => :was_checked? do |t|
    t.validates_presence_of :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days
    t.validates_presence_of :observer, :if => :observer_id
    t.validate :dates_validity
  end 

  with_options :if => :was_noticed_or_refused_by_director? do |t|
    t.validates_presence_of :director_id, :ended_at
    t.validates_presence_of :director, :if => :director_id
    t.validate :dates_validity
    t.validates_presence_of :director_remarks, :if => :director_agreement_is_false?
  end
  
  validates_persistence_of :employee, :employee_id, :start_date, :end_date, :leave_type_id, :start_half, :end_half, :comment, :if => :higher_than_step_submit?
  validates_persistence_of :responsible, :responsible_id, :checked_at, :responsible_agreement, :responsible_remarks, :if => :higher_than_step_check?
  validates_persistence_of :observer, :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days, :if => :higher_than_step_notice?
  
  # Validates methods

  def dates_coherence_order
    if self.start_date != nil and self.end_date != nil
      errors.add(:end_date, "ne peut être antérieure à la date de début !") if self.start_date > self.end_date
    end
  end
  
  def dates_coherence_validity
    if self.start_date != nil
      errors.add(:start_date, "ne peut être antérieure à aujourd'hui !") if self.start_date < Date.today
    end
  end
  
  def same_dates_and_a_half_max
    if self.start_date != nil and self.end_date != nil
      errors.add(:end_half, "ne peut être sélectionné en même temps que start half pour deux dates semblables !") if self.start_date == self.end_date and self.start_half and self.end_half
    end
  end

  def dates_validity
    if self.start_date != nil
      errors.add(:start_date, "a expiré, veuillez annuler la demande") if self.start_date < Date.today
    end
  end

  # Methods

  def responsible_agreement_is_false?
    self.responsible_agreement == false
  end

  def director_agreement_is_false?
    self.director_agreement == false
  end

  def can_be_submitted?
    self.unstarted?
  end

  def can_be_checked?
    self.submitted_or_refused_by_responsible?
  end

  def can_be_noticed?
    self.checked?
  end

  def can_be_closed?
    self.noticed_or_refused_by_director?
  end

  def can_be_cancelled?
    self.start_date < Date.today and ![nil,STATUS_CANCELLED,STATUS_CLOSED].include?(self.status)
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
    end
  end

  def notice
    if can_be_noticed?
      self.status = STATUS_NOTICED  
    end
  end
  
  def close
    if can_be_closed?
      if self.director_agreement
        self.status = STATUS_CLOSED   
      else
        self.status = STATUS_REFUSED_BY_DIRECTOR
      end
    end
  end

  def cancel(employee_id)
    if can_be_cancelled?
      self.cancelled_by = employee_id
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED  
      self.save
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
    self.status_was == STATUS_SUBMITTED
  end
  
  def was_checked?
    self.status_was == STATUS_CHECKED
  end
  
  def was_refused_by_responsible?
    self.status_was == STATUS_REFUSED_BY_RESPONSIBLE
  end
  
  def was_noticed?
    self.status_was == STATUS_NOTICED
  end
  
  def was_closed?
    self.status_was == STATUS_CLOSED
  end
  
  def was_refused_by_director?
    self.status_was == STATUS_REFUSED_BY_DIRECTOR
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
  
end
