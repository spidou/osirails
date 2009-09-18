class ToolEvent < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :legal_paper, :invoice, :expence_account, :other
  
  # Type Constants
  INTERVENTION = 1
  INCIDENT     = 2
  TYPE_TEXT    = {INTERVENTION => 'Intervention', INCIDENT => 'Incident'}
  
  # Status Constants
  AVAILABLE   = 0
  UNAVAILABLE = 1
  SCRAPPED    = 2
  STATUS_TEXT = {AVAILABLE => 'Disponible', UNAVAILABLE => 'Indisponible', SCRAPPED => 'Mis au rebut'}
  
  TOOL_EVENTS_PER_PAGE = 15
  
  named_scope :effectives, :conditions => ["start_date<=?", Date.today], :order => 'start_date DESC, id DESC'
  named_scope :scheduled,  :conditions => ["start_date>?", Date.today], :order => 'start_date DESC, id DESC'
  named_scope :currents,   :conditions => ['(start_date<=? and end_date>=? and event_type=?) or (start_date=?)', Date.today, Date.today, INTERVENTION, Date.today], :order => 'start_date DESC, id DESC'
  named_scope :last_three, :limit => 3, :order => 'start_date DESC, id DESC'
  
  # relationships
  belongs_to :tool
  belongs_to :internal_actor, :class_name => "Employee"
  belongs_to :event,          :dependent => :delete
  
  # validates
  validates_inclusion_of :event_type,        :in => [INTERVENTION, INCIDENT]
  validates_inclusion_of :status,            :in => [AVAILABLE, UNAVAILABLE, SCRAPPED], :if => Proc.new {|n| n.event_type == INCIDENT}
  validates_inclusion_of :status,            :in => [AVAILABLE, UNAVAILABLE],           :if => Proc.new {|n| n.event_type == INTERVENTION}
 
  validates_presence_of :start_date, :name, :comment, :tool_id, :internal_actor_id
  validates_presence_of :tool,               :if => :tool_id
  validates_presence_of :internal_actor,     :if => :internal_actor_id
  validates_presence_of :end_date,           :if => Proc.new {|n| n.event_type == INTERVENTION}
  
  validates_persistence_of :event_type,      :unless => Proc.new {|n| n.new_record?}
  
  validate :validates_date_is_correct,       :if => :end_date
  validate :validates_tool_is_not_scrapped,  :if => :tool
  
  validates_associated :event
  
  # callbacks
  after_update :save_event
  before_validation :prepare_event
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:name]             = "Désignation :"
  @@form_labels[:event_type]       = "Type :"
  @@form_labels[:status]           = "Status de l'équipement :"
  @@form_labels[:internal_actor]   = "Acteur interne :"
  @@form_labels[:provider_society] = "Entreprise prestataire :"
  @@form_labels[:provider_actor]   = "Représentant prestataire :"
  @@form_labels[:start_date]       = "Date de début :"
  @@form_labels[:end_date]         = "Date de fin :"
  @@form_labels[:comment]          = "Commentaire :"
  
  def calendar_duration
    return nil if event_type == INCIDENT
    return 0 if [end_date, start_date].include? nil
    (end_date - start_date).to_i + 1
  end
  
  def event_type_name
    {1 => 'intervention', 2 => 'incident'}[event_type]
  end
  
  # this method permit to save the alarms of the event when it is passed with the tool_event form
  def alarm_attributes=(alarm_attributes)
    prepare_event                 # call here prepare event because 'before_validation' call_back is called after 'attributes=' then after 'alarm_attributes='
    alarm_attributes.each do |attributes|
      if attributes[:id].blank?
        alarm = event.alarms.build(attributes)
        alarm.event = event
      else
        alarm = event.alarms.detect {|t| t.id == attributes[:id].to_i} 
        alarm.attributes = attributes
      end
    end
  end
  
  def title
    ( tool ? tool.name.to_s + " : " : "" ) + name.to_s
  end
  
  private
    
    def validates_date_is_correct
      if start_date > end_date
        errors.add(:start_date, "est postérieure à la date de fin")
        errors.add(:end_date, "est antérieure à la date de début")
      end
    end
    
    def validates_tool_is_not_scrapped
      errors.add(:tool_id, "L'ajout ou la modification d'un évènement pour cet équipement est impossible car celui-ci a été mis au rebut") unless tool.can_be_edited?
    end
    
    def save_event
      event.save(false)
    end
    
    # TODO when the calendar will handle event on many days modify the event preparation, to put 'end_date' into 'end_at'
    # the commented line assume that when it's an 'incident' the 'end_date' is nil, but if not into validations a test may be done to be sure 
    def prepare_event
      calendar = Calendar.find_or_create_by_name("equipments_calendar")
      event_attributes                = {}
      event_attributes[:calendar_id]  = calendar.id
      event_attributes[:full_day]     = true
      event_attributes[:start_at]     = start_date.to_datetime unless start_date.nil?
      event_attributes[:end_at]       = start_date.to_datetime unless start_date.nil? # (end_date || start_date).to_datetime unless [start_date, end_ate].include?(nil)
      event_attributes[:title]        = title
      event_attributes[:description]  = comment
      event_attributes[:organizer_id] = internal_actor_id
      
      if event.nil?
        build_event(event_attributes)
      else
        event.attributes = event_attributes
      end
    end
end
