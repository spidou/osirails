class Tool < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :tool_events
  belongs_to :service
  belongs_to :job
  belongs_to :employee
  belongs_to :supplier
  
  validates_presence_of :name, :description, :purchase_date
  validates_presence_of :service_id, :employee_id, :supplier_id
  validates_presence_of :service,  :if => :service_id
  validates_presence_of :job,      :if => :job_id,            :message => "doit être un poste valide"
  validates_presence_of :employee, :if => :employee_id
  validates_presence_of :supplier, :if => :supplier_id
  
  validates_numericality_of :purchase_price
  
  validate :validates_edit
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:status]         = "Status :"
  @@form_labels[:type]           = "Type :"
  @@form_labels[:name]           = "Désignation :"
  @@form_labels[:description]    = "Description :"
  @@form_labels[:serial_number]  = "Numéro de série :"
  @@form_labels[:purchase_date]  = "Date d'achat :"
  @@form_labels[:purchase_price] = "Prix d'achat :"
  @@form_labels[:service]        = "Service :"
  @@form_labels[:job]            = "Poste :"
  @@form_labels[:employee]       = "Employé :"
  @@form_labels[:supplier]       = "Fournisseur :"
  
  def status
    status = {:scrapped => ToolEvent::SCRAPPED, :available => ToolEvent::AVAILABLE, :unavailable => ToolEvent::UNAVAILABLE}
    type   = {:intervention => ToolEvent::INTERVENTION, :incident => ToolEvent::INCIDENT}
    
    last_event = tool_events.effectives.last
    
    return status[:available] if tool_events.empty? or last_event.nil?
    return status[:scrapped] if has_one_scrapped?

    case last_event.event_type
      when type[:incident]
        return last_event.start_date == Date.today ? last_event.status : status[:available]
      when type[:intervention]
        return last_event.end_date >= Date.today ? last_event.status : status[:available]
    end
  end
  
  def has_one_scrapped?
    !tool_events.all(:conditions => ["status=?", 2], :limit => 1).empty?
  end
  
  def can_be_edited?
    status != ToolEvent::SCRAPPED
  end
  
  private
  
    def validates_edit
      errors.add_to_base("L'équipement ne peut plus être modifié car il a été mis au rebut") if !new_record? and !can_be_edited?
    end
end
