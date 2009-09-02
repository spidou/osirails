class ToolEvent < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :legal_paper, :invoice, :expence_account, :other
  
  # Type Constants
  INTERVENTION = 1
  INCIDENT     = 2
  TYPE_TEXT   = {INTERVENTION => 'Intervention', INCIDENT => 'Incident'}
  
  # Status Constants
  AVAILABLE   = 0
  UNAVAILABLE = 1
  SCRAPPED    = 2
  STATUS_TEXT = {AVAILABLE => 'Disponible', UNAVAILABLE => 'Indisponible', SCRAPPED => 'Mis au rebut'}
  
  named_scope :effectives, :conditions => ["start_date<=?", Date.today]
  named_scope :scheduled, :conditions => ["start_date>?", Date.today] 
  
  belongs_to :tool
  belongs_to :internal_actor, :class_name => "Employee"
  
  validates_inclusion_of :event_type, :in => [INTERVENTION, INCIDENT]
  validates_inclusion_of :status,            :in => [AVAILABLE, UNAVAILABLE, SCRAPPED], :if => Proc.new {|n| n.event_type == INCIDENT}
  validates_inclusion_of :status,            :in => [AVAILABLE, UNAVAILABLE],           :if => Proc.new {|n| n.event_type == INTERVENTION}
 
  validates_presence_of :start_date, :comment, :tool_id
  validates_presence_of :tool,               :if => :tool_id
  validates_presence_of :internal_actor,     :if => :internal_actor_id,                 :message => "doit être un employé valide"
  validates_presence_of :end_date,           :if => Proc.new {|n| n.event_type == INTERVENTION}
  
  validate :validates_date_is_correct,       :if => :end_date
  validate :validates_tool_is_not_scrapped,  :if => :tool
  
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
  
  private
    
    def validates_date_is_correct
      if start_date > end_date
        errors.add :start_date, "ne dois pas être plus grand que end_date"
        errors.add :end_date, "ne dois pas être plus petit que start_date"
      end
    end
    
    def validates_tool_is_not_scrapped
      errors.add(:tool_id, "L'évènement ne peut être ajouté ou édité car l'équipement a été mis au rebut") unless Tool.find(tool_id).can_be_edited?
    end

end
