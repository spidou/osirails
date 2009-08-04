class LeaveRequest < ActiveRecord::Base

  # Relationships

  belongs_to :employee
  belongs_to :responsible, :class_name => "Employee", :foreign_key => "responsible_id"
  belongs_to :observer, :class_name => "Employee", :foreign_key => "observer_id"
  belongs_to :director, :class_name => "Employee", :foreign_key => "director_id"

  # Constants
  def is_level_submitted_or_refused_by_responsible?
    return true if (self.is_status_submitted? or self.is_status_refused_by_responsible?)
  end
  STATUS_CANCELLED = 0
  STATUS_SUBMITTED = 1
  STATUS_CHECKED = 2
  STATUS_REFUSED_BY_RESPONSIBLE = -2
  STATUS_NOTICED = 3
  STATUS_CLOSED = 4
  STATUS_REFUSED_BY_DIRECTOR = -4
  STATUS_VALIDATED = 5

  # Validates
  ##TODO Dates validations
  
  with_options :if => :is_status_submitted? do |t|
    t.validates_presence_of :employee_id, :start_date, :end_date, :leave_type_id
    t.validates_presence_of :employee, :if => :employee_id
    t.validates_numericality_of :employee_id, :leave_type_id
    t.validate :dates_order
  end

  with_options :if => :is_status_checked_or_refused_by_responsible? do |t|
    t.validates_presence_of :responsible_id, :checked_at
    t.validates_presence_of :responsible, :if => :responsible_id
    t.validates_numericality_of :responsible_id
    t.validate :dates_validity
    t.validates_presence_of :responsible_remarks, :if => :responsible_agreement_is_false?
  end

  with_options :if => :is_status_noticed? do |t|
    t.validates_presence_of :observer_id, :noticed_at, :observer_remarks, :acquired_leaves_days
    t.validates_presence_of :observer, :if => :observer_id
    t.validates_numericality_of :observer_id, :acquired_leaves_days
    t.validate :dates_validity
  end 

  with_options :if => :is_status_closed_or_refused_by_director? do |t|
    t.validates_presence_of :director_id, :ended_at
    t.validates_presence_of :director, :if => :director_id
    t.validates_numericality_of :director_id
    t.validate :dates_validity
    t.validates_presence_of :director_remarks, :if => :director_agreement_is_false?
  end

  # Validates methods

  def dates_order
    if self.start_date != nil and self.end_date != nil
      errors.add(:end_date, "La date de fin de congé ne peut être antérieur à la date de début !") if self.start_date > self.end_date
    end
  end

  def dates_validity
    if self.start_date != nil
      errors.add(:start_date, "La date de début de congé a expiré, veuillez annuler la demande") if self.start_date < Date.today
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
    self.status == nil
  end

  def can_be_checked?
    [STATUS_REFUSED_BY_RESPONSIBLE,STATUS_SUBMITTED].include?(self.status)
  end

  def can_be_noticed?
    self.status == STATUS_CHECKED
  end

  def can_be_closed?
    [STATUS_REFUSED_BY_DIRECTOR,STATUS_NOTICED].include?(self.status)
  end

  def can_be_validated?
    self.status == STATUS_CLOSED
  end

  def can_be_cancelled?
    self.start_date < Date.today and ![nil,STATUS_CANCELLED,STATUS_CLOSED,STATUS_VALIDATED].include?(self.status)
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
        self.save
      else
        self.status = STATUS_REFUSED_BY_RESPONSIBLE
        self.save
      end
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
        self.save
      else
        self.status = STATUS_REFUSED_BY_DIRECTOR
        self.save
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

  def change_status_to_validated
    if can_be_validated?
      self.status = STATUS_VALIDATED
      self.save
    end
  end
  
  def is_status_nil?
    self.status == nil
  end
  
  def is_status_cancelled?
    self.status == STATUS_CANCELLED
  end
  
  def is_status_submitted?
    self.status == STATUS_SUBMITTED
  end
  
  def is_status_checked?
    self.status == STATUS_CHECKED
  end
  
  def is_status_refused_by_responsible?
    self.status == STATUS_REFUSED_BY_RESPONSIBLE
  end
  
  def is_status_noticed?
    self.status == STATUS_NOTICED
  end
  
  def is_status_closed?
    self.status == STATUS_CLOSED
  end
  
  def is_status_refused_by_director?
    self.status == STATUS_REFUSED_BY_DIRECTOR
  end
  
  def is_status_validated?
    self.status == STATUS_VALIDATED
  end
  
  def is_status_checked_or_refused_by_responsible?
    self.is_status_checked? or self.is_status_refused_by_responsible?
  end
  
  def is_status_closed_or_refused_by_director?
    self.is_status_closed? or self.is_status_refused_by_director?
  end
  
end
