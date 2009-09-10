class LeaveRequest < ActiveRecord::Base
  include LeaveAndLeaveRequest
  
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :delete, :submit, :check, :notice, :close, :cancel]
  
  alias_attribute :submitted_at, :created_at
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:status]                = "STATUT :"
  @@form_labels[:employee]              = "Employé :"
  @@form_labels[:submitted_at]          = "Date de la demande :"
  @@form_labels[:period]                = "Date/Période demandée :"
  @@form_labels[:start_date]            = "Du :"
  @@form_labels[:end_date]              = "Au :"
  @@form_labels[:start_half]            = "depuis la mi-journée ?"
  @@form_labels[:end_half]              = "jusqu'à la mi-journée ?"
  @@form_labels[:leave_type]            = "Type du congé :"
  @@form_labels[:comment]               = "Commentaire :"
  @@form_labels[:responsible_agreement] = "Réponse du responsable :"
  @@form_labels[:checked_at]            = "Date :"
  @@form_labels[:responsible]           = "Nom du responsable :"
  @@form_labels[:responsible_remarks]   = "Commentaire :"
  @@form_labels[:acquired_leaves_days]  = "Etat des congés payés acquis :"
  @@form_labels[:duration]              = "Durée effective totale :"
  @@form_labels[:observer_remarks]      = "Observations :"
  @@form_labels[:observer]              = "Notifié par :"
  @@form_labels[:noticed_at]            = "Date :"
  @@form_labels[:director]              = "Clôturé par :"
  @@form_labels[:director_agreement]    = "Réponse de la direction :"
  @@form_labels[:agreement_true]        = "ACCORD :"
  @@form_labels[:agreement_false]       = "REFUS :"
  @@form_labels[:director_remarks]      = "Commentaire :"
  @@form_labels[:ended_at]              = "Date :"
  @@form_labels[:cancelled_at]          = "Annulée le :"
  
  LEAVE_REQUESTS_PER_PAGE = 15
  
  STATUS_CANCELLED = 0
  STATUS_SUBMITTED = 1
  STATUS_CHECKED = 2
  STATUS_REFUSED_BY_RESPONSIBLE = -2
  STATUS_NOTICED = 3
  STATUS_CLOSED = 4
  STATUS_REFUSED_BY_DIRECTOR = -4
  
  named_scope :leave_requests_to_notice,  :conditions => ["status = ?", LeaveRequest::STATUS_CHECKED],
                                          :order => "start_date DESC"
  named_scope :leave_requests_to_close,   :conditions => ["status = ?", LeaveRequest::STATUS_NOTICED],
                                          :order => "start_date DESC"
  
  has_one :leave
  
  belongs_to :employee
  belongs_to :responsible, :class_name => "Employee", :foreign_key => "responsible_id"
  belongs_to :observer, :class_name => "Employee", :foreign_key => "observer_id"
  belongs_to :director, :class_name => "Employee", :foreign_key => "director_id"
  belongs_to :leave_type
  
  before_save :build_associated_leave
  
  # Validates
  ##TODO Dates validations
  
  with_options :if => :was_unstarted? do |t|
    t.validates_presence_of :start_date, :end_date
    t.validates_presence_of :employee_id, :leave_type_id
    t.validates_presence_of :employee,   :if => :employee_id
    t.validates_presence_of :leave_type, :if => :leave_type_id
    
    t.validate :validates_unique_dates
  end
  
  with_options :if => :was_submitted_or_refused_by_responsible? do |t|
    t.validates_presence_of :responsible_id, :checked_at
    t.validates_presence_of :responsible, :if => :responsible_id
  end
  
  with_options :if => :was_checked? do |t|
    t.validates_presence_of :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days, :duration
    t.validates_presence_of :observer, :if => :observer_id
  end 
  
  with_options :if => :was_noticed_or_refused_by_director? do |t|
    t.validates_presence_of :director_id, :ended_at
    t.validates_presence_of :director, :if => :director_id
  end
  
  validate :validates_start_date_validity,  :if => :start_date
  validate :validates_dates_consistency,    :if => :start_date_and_end_date
  
  validates_presence_of :responsible_remarks, :if => :validates_responsible_remarks
  validates_presence_of :director_remarks,    :if => :validates_director_remarks
  
  validates_persistence_of :employee, :employee_id, :start_date, :end_date, :leave_type_id, :start_half, :end_half, :comment, :if => :higher_than_step_submit?
  validates_persistence_of :responsible, :responsible_id, :checked_at, :responsible_agreement, :responsible_remarks,          :if => :higher_than_step_check?
  validates_persistence_of :observer, :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days, :duration,         :if => :higher_than_step_notice?
  
  validates_associated :leave, :if => :closed?
  
  def validates_start_date_validity
    if start_date < Date.today
      if was_unstarted?
        error = "est antérieure à aujourd'hui"
      else
        error = "La demande a expiré, vous devez annuler ou supprimer la demande actuelle et en créer une nouvelle"
      end
      errors.add(:start_date, error)
    end
  end
  
  def validates_unique_dates
    check_unique_dates(conflicting_leaves(employee.future_leaves + employee.in_progress_leave_requests)) if employee
  end
  
  def validates_responsible_remarks
    !responsible_agreement and was_submitted_or_refused_by_responsible?
  end
  
  def validates_director_remarks
    !director_agreement and was_noticed_or_refused_by_director?
  end
  
  def build_associated_leave
    if leave_can_be_created?
      leave = build_leave(:leave_request_id  => id,
                          :employee_id       => employee_id,
                          :start_date        => start_date,
                          :end_date          => end_date,
                          :start_half        => start_half,
                          :end_half          => end_half,
                          :leave_type_id     => leave_type_id, 
                          :duration          => duration)
    end  
  end
  
  def can_be_submitted?
    was_unstarted?
  end
  
  def can_be_checked?
    was_submitted_or_refused_by_responsible?
  end
  
  def can_be_noticed?
    was_checked?
  end
  
  def can_be_closed?
    was_noticed_or_refused_by_director?
  end
  
  def leave_can_be_created?
    closed?
  end
  
  def can_be_cancelled?
    ![nil,STATUS_CANCELLED,STATUS_CLOSED].include?(status)
  end
  
  def submit
    if can_be_submitted?
      self.status = STATUS_SUBMITTED
      save
    end
  end
  
  def check
    if can_be_checked?
      if responsible_agreement
        self.status = STATUS_CHECKED 
      else
        self.status = STATUS_REFUSED_BY_RESPONSIBLE
      end
      self.checked_at = Time.now
      save
    end
  end
  
  def notice
    if can_be_noticed?
      self.status = STATUS_NOTICED 
      self.noticed_at = Time.now
      save 
    end
  end
  
  def close 
    if can_be_closed?
      if director_agreement
        self.status = STATUS_CLOSED   
      else
        self.status = STATUS_REFUSED_BY_DIRECTOR
      end
      self.ended_at = Time.now
      save
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED  
      save
    end
  end
  
  def unstarted?
    status.nil?
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def submitted?
    status == STATUS_SUBMITTED
  end
  
  def checked?
    status == STATUS_CHECKED
  end
  
  def refused_by_responsible?
    status == STATUS_REFUSED_BY_RESPONSIBLE
  end
  
  def noticed?
    status == STATUS_NOTICED
  end
  
  def closed?
    status == STATUS_CLOSED
  end
  
  def refused_by_director?
    status == STATUS_REFUSED_BY_DIRECTOR
  end
  
  def submitted_or_refused_by_responsible?
    submitted? or refused_by_responsible?
  end
  
  def noticed_or_refused_by_director?
    noticed? or refused_by_director?
  end
  
  def was_unstarted?
    status_was.nil?
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def was_submitted?
    status_was == STATUS_SUBMITTED and !cancelled?
  end
  
  def was_checked?
    status_was == STATUS_CHECKED and !cancelled?
  end
  
  def was_refused_by_responsible?
    status_was == STATUS_REFUSED_BY_RESPONSIBLE and !cancelled?
  end
  
  def was_noticed?
    status_was == STATUS_NOTICED and !cancelled?
  end
  
  def was_closed?
    status_was == STATUS_CLOSED and !cancelled?
  end
  
  def was_refused_by_director?
    status_was == STATUS_REFUSED_BY_DIRECTOR and !cancelled?
  end
  
  def was_submitted_or_refused_by_responsible?
    was_submitted? or was_refused_by_responsible?
  end
  
  def was_noticed_or_refused_by_director?
    was_noticed? or was_refused_by_director?
  end
  
  def higher_than_step_submit?
    checked? or refused_by_responsible? or higher_than_step_check?
  end
  
  def higher_than_step_check?
    noticed? or higher_than_step_notice?
  end
  
  def higher_than_step_notice?
    closed? or refused_by_director?
  end
  
  def was_higher_than_step_unstarted?
    was_submitted? or was_higher_than_step_submit?
  end
  
  def was_higher_than_step_submit?
    was_checked? or was_refused_by_responsible? or was_higher_than_step_check?
  end
  
  def was_higher_than_step_check?
    was_noticed? or was_higher_than_step_notice?
  end
  
  def was_higher_than_step_notice?
    was_closed? or was_refused_by_director?
  end
  
end
