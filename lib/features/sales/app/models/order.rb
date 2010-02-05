class Order < ActiveRecord::Base
  has_permissions :as_business_object
  has_address     :bill_to_address
  has_contacts    :accept_from => :customer_contacts
  has_reference   :prefix => :sales
  
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :commercial, :class_name => 'Employee'
  belongs_to :creator,    :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :approaching
  
  # steps
  has_one :commercial_step,    :dependent => :nullify
  has_one :pre_invoicing_step, :dependent => :nullify
  has_one :invoicing_step,     :dependent => :nullify
  
  # quotes
  has_many :quotes, :order => 'created_at DESC'
  has_one  :draft_quote,   :class_name => 'Quote', :conditions => [ 'status IS ?', nil ]
  has_one  :pending_quote, :class_name => 'Quote', :conditions => [ 'status IN (?)', [ Quote::STATUS_CONFIRMED, Quote::STATUS_SENDED ] ]
  has_one  :signed_quote,  :class_name => 'Quote', :conditions => [ "status = ?", Quote::STATUS_SIGNED ]
  #TODO validate if the order counts only one signed quote (draft_quote and pending_quote) at time!
  
  # press_proofs
  has_many :press_proofs
  # TODO add the corresponding test
  
  # delivery notes
  has_many :delivery_notes
  has_one  :uncomplete_delivery_note, :class_name => 'DeliveryNote', :conditions => [ 'status IS NULL' ]
  has_many :signed_delivery_notes,    :class_name => 'DeliveryNote', :conditions => [ "status = ?", DeliveryNote::STATUS_SIGNED ]
  
  has_many :ship_to_addresses
  has_many :products
  has_many :order_logs
  has_many :mockups
  has_many :graphic_documents

  validates_presence_of :title, :previsional_delivery, :customer_needs, :bill_to_address
  validates_presence_of :customer_id, :society_activity_sector_id, :commercial_id, :user_id, :approaching_id
  validates_presence_of :customer,                :if => :customer_id
  validates_presence_of :society_activity_sector, :if => :society_activity_sector_id
  validates_presence_of :commercial,              :if => :commercial_id
  validates_presence_of :creator,                 :if => :user_id
  validates_presence_of :approaching,             :if => :approaching_id
  validates_presence_of :order_type_id,           :if => :society_activity_sector
  validates_presence_of :order_type,              :if => :order_type_id
  
# validates_uniqueness_of :reference #TODO do not forget to implement that according to the reference generation
  
  validates_contact_length :minimum => 1, :too_short => "Vous devez choisir au moins 1 contact"
  
  validates_associated :customer, :ship_to_addresses, :products, :quotes #TODO quotes is really necessary ?
  
  validate :validates_length_of_ship_to_addresses
  validate :validates_order_type_validity
  #TODO validates_date :previsional_delivery (check if the date is correct, if it's after order creation date), etc. )
  
  after_save   :save_ship_to_addresses, :save_ship_to_addresses_from_new_establishments
  after_create :create_steps
  
  # level constants
  CRITICAL  = 'critical'
  LATE      = 'late'
  TODAY     = 'today'
  SOON      = 'soon'
  FAR       = 'far'
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:title]                   = "Nom du projet :"
  @@form_labels[:customer_needs]          = "Besoins du client :"
  @@form_labels[:society_activity_sector] = "Secteur d'activité :"
  @@form_labels[:order_type]              = "Type de dossier :"
  @@form_labels[:commercial]              = "Commercial :"
  @@form_labels[:ship_to_address]         = "Adresse(s) de livraison :"
  @@form_labels[:approaching]             = "Type d'approche :"
  @@form_labels[:contact]                 = "Contact commercial :"
  @@form_labels[:created_at]              = "Date de création :"
  @@form_labels[:previsional_delivery]    = "Date prévisionnelle de livraison :"
  @@form_labels[:quotation_deadline]      = "Date butoire d'envoi du devis :"
  
  # Return all steps of the order according to the choosen order type
  def steps
    raise "You must configure an order type for the current order before trying to retrieve its steps. Perhaps the order is a new record and has not been created yet?" if order_type.nil?
    order_type.activated_steps
  end
  
  # Returns steps of the first level
  # 
  # order:
  #   commercial_step
  #     graphic_conception_step
  #     survey_step
  #     estimate_step
  #   invoicing_step
  #     invoice_step
  #     payment_step
  # 
  # @order.first_level_steps # => [ #<CommercialStep>, #<InvoicingStep> ]
  # 
  def first_level_steps
    steps.select{ |step| !step.parent }.map{ |step| send(step.name) }
  end
  
  # Returns all steps
  # 
  # order:
  #   commercial_step
  #     graphic_conception_step
  #     survey_step
  #     estimate_step
  #   invoicing_step
  #     invoice_step
  #     payment_step
  # 
  # @order.all_steps # => [ #<CommercialStep>, #<GraphicConceptionStep>, #<SurveyStep>, ... ]
  # 
  def all_steps
    first_level_steps.collect { |step| [step] << step.children_steps }.flatten
  end
  
  def current_first_level_step
    first_level_steps.each do |child|
      return child unless child.terminated?
    end
    return first_level_steps.last
  end
  
  def current_step
#    return default_step if new_record?
    children_steps = all_steps.select{ |step| step.respond_to?(:parent_step) }
    children_steps.each do |child|
      return child unless child.terminated?
    end
    return children_steps.last
  end

  # Return a hash for advance statistics
  def advance
    steps_obj = []
    advance = {}
    steps.each do |step|
      next if step.parent
      steps_obj += send(step.name).children_steps
    end
    advance[:total] = steps_obj.size
    advance[:terminated] = 0
    steps_obj.each { |s| advance[:terminated] += 1 if s.terminated? }
    advance
  end

#  def child
#    first_level_steps.reverse.each do |child|
#      return child unless child.unstarted?
#    end
#    return first_level_steps.first
#  end

  ## Return missing elements's order
  def missing_elements
    missing_elements = []
    OrdersSteps.find(:all, :conditions => ["order_id = ?", self.id]).each {|order_step| order_step.missing_elements.each {|missing_element| missing_elements << missing_element} }
    missing_elements
  end
  
  def terminated?
    return false unless closed_at?
    children_steps.each do |child|
      return false unless child.terminated?
    end
    true
  end
  
  def critical_status
    return unless previsional_delivery
    delay = (Date.today - previsional_delivery.to_date).to_i
    
    if delay < -14
      FAR
    elsif delay < 0
      SOON
    elsif delay > 7
      CRITICAL
    elsif delay > 0
      LATE
    elsif delay == 0
      TODAY
    end
  end
  
  #def signed_quote
  #  commercial_step.estimate_step.signed_quote
  #end
  
  def customer_contacts
    # customer.all_contacts #TODO also take in account contacts in customer's establishments
    customer ? customer.contacts : []
  end
  
  def customer_establishments
    customer ? customer.establishments : []
  end
  
  def build_ship_to_address(establishment)
    raise "establishment expected to be already saved" if establishment.new_record?
    
    ship_to_addresses.build(:establishment_name => establishment.name,
                            :should_create      => 1).build_address(establishment.address.attributes)
  end
  
  def establishment_attributes=(establishment_attributes)
    raise "customer expected to be not nil" unless customer
    establishment_attributes.each do |attributes|
      establishment = customer.build_establishment(attributes)
      establishment.ship_to_addresses.build(:establishment_name => attributes[:name],
                                            :parallel_creation  => true,
                                            :should_create      => 1).build_address(attributes[:address_attributes])
    end
  end
  
  def ship_to_address_attributes=(ship_to_address_attributes)
    ship_to_address_attributes.each do |attributes|
      raise "attributes hash expected to have :establishment_id key" unless attributes[:establishment_id]
      establishment = Establishment.find(attributes[:establishment_id])
      if attributes[:id].blank?
        if attributes[:should_create].to_i == 1
          ship_to_addresses.build({ :establishment_name => establishment.name }.merge(attributes)).build_address(establishment.address.attributes)
        end
      else
        ship_to_address = ship_to_addresses.detect { |t| t.id == attributes[:id].to_i }
        ship_to_address.attributes = attributes
      end
    end
  end
  
  def save_ship_to_addresses
    ship_to_addresses.each do |s|
      if s.should_create?
        s.save(false)
      elsif s.should_destroy?
        s.destroy
      end
    end
  end
  
  def save_ship_to_addresses_from_new_establishments
    raise "customer expected to be not nil" unless customer
    customer.establishments.select{|e|e.new_record?}.each do |establishment|
      establishment.save(false)
      establishment.ship_to_addresses.each do |s|
        s.order_id = self.id
        s.save(false)
      end
    end
  end
  
  def validates_length_of_ship_to_addresses
    if ship_to_addresses.select{ |s| (s.new_record? and s.should_create) or (!s.new_record? and !s.should_destroy?) }.empty?
      errors.add(:ship_to_address_ids, "Vous devez choisir au moins 1 adresse de livraison")
    end
  end
  
  private
#    def default_step
#      Step.find_by_name("commercial_step")
#    end
  # Create all orders_steps after create order
    
    def validates_order_type_validity
      if order_type and society_activity_sector
        errors.add(:order_type_id, ActiveRecord::Errors.default_error_messages[:inclusion]) unless society_activity_sector.order_types.include?(order_type)
      end
    end
    
    def create_steps
      steps.each do |step|
        if step.parent.nil?
          step.name.camelize.constantize.create(:order_id => self.id)
        else
          step_model = step.name.camelize.constantize                # eg: SurveyStep
          parent_step_model = step.parent.name.camelize.constantize  # eg: CommercialStep
          
          step_model.create!(parent_step_model.table_name.singularize + '_id' => self.send(step.parent.name).id)
        end
      end
      
      activate_first_step
    end
    
    def activate_first_step
      first_level_steps.first.pending!
    end
    
    # that method permits to bound the new contact with the customer of the order.
    # after that, the contact which is first created for the customer, is associated to the order in a second time
    def save_contacts_with_order_support
      contacts.each do |contact|
        unless customer.contacts.include?(contact)
          customer.contacts << contact
        end
      end
      
      save_contacts_without_order_support
    end
    
    alias_method_chain :save_contacts, :order_support
end
