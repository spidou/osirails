class Tool < ActiveRecord::Base # @abstract
  has_many :tool_events
  
  belongs_to :service
  belongs_to :job
  belongs_to :employee
  belongs_to :supplier
  
  validates_presence_of :name, :purchase_date, :serial_number, :service_id
  validates_presence_of :service,  :if => :service_id
  
  validates_numericality_of :purchase_price
  
  validate :validates_edit
  
  journalize :identifier_method => :name_and_serial_number
  
  def status
    all_current_status = tool_events.currents.collect(&:status)
    status             = {:scrapped => ToolEvent::SCRAPPED, :available => ToolEvent::AVAILABLE, :unavailable => ToolEvent::UNAVAILABLE}
    
    return status[:available] if tool_events.empty?
    return status[:scrapped]  if has_one_scrapped?   
    return all_current_status.include?(status[:unavailable]) ? status[:unavailable] : status[:available]   
  end
  
  def has_one_scrapped?
    !tool_events.all(:conditions => ["status=? and start_date<=?", ToolEvent::SCRAPPED, Date.today], :limit => 1).empty?
  end
  
  def can_be_edited?
    status != ToolEvent::SCRAPPED
  end
  
  def name_and_serial_number
    "#{name} (#{serial_number})"
  end
  
  private
    def validates_edit
      errors.add_to_base("L'équipement ne peut plus être modifié car il a été mis au rebut") if !new_record? and !can_be_edited?
    end
end
