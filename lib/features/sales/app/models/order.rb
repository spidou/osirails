class Order < ActiveRecord::Base
  has_permissions :as_business_object
  has_address     :bill_to_address
  has_contact     :order_contact, :accept_from => :customer_contacts, :required => true
  has_reference   :prefix => :sales
  
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :commercial, :class_name => 'Employee'
  belongs_to :creator,    :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :approaching
  
  # steps
  has_one :commercial_step, :dependent => :nullify
  has_one :production_step, :dependent => :nullify
  has_one :invoicing_step,  :dependent => :nullify
  
  # quotes
  has_many :quotes, :order => 'created_at DESC'
  has_one  :draft_quote,   :class_name => 'Quote', :conditions => [ 'status IS NULL' ]
  has_one  :pending_quote, :class_name => 'Quote', :conditions => [ 'status IN (?)', [ Quote::STATUS_CONFIRMED, Quote::STATUS_SENDED ] ]
  has_one  :signed_quote,  :class_name => 'Quote', :conditions => [ 'status = ?', Quote::STATUS_SIGNED ]
  #TODO validate if the order counts only one signed quote (draft_quote and pending_quote) at time!
  
  # press_proofs
  has_many :press_proofs, :order => 'created_at DESC'
  # TODO add the corresponding test
  
  # delivery notes
  has_many :delivery_notes, :order => 'created_at DESC'
  has_many :uncomplete_delivery_notes,  :class_name => 'DeliveryNote', :conditions => [ 'status IS NULL' ], :order => "created_at DESC"
  has_many :signed_delivery_notes,      :class_name => 'DeliveryNote', :conditions => [ "status = ?", DeliveryNote::STATUS_SIGNED ], :order => "created_at DESC"
  
  # invoices
  has_many :invoices, :order => 'invoices.created_at DESC'
  
  has_many :ship_to_addresses
  has_many :end_products, :conditions => [ "cancelled_at IS NULL" ]
  has_many :order_logs
  has_many :mockups
  has_many :graphic_documents
  
  validates_presence_of :reference, :title, :previsional_delivery, :customer_needs, :bill_to_address
  validates_presence_of :customer_id, :society_activity_sector_id, :commercial_id, :user_id, :approaching_id
  validates_presence_of :customer,                :if => :customer_id
  validates_presence_of :society_activity_sector, :if => :society_activity_sector_id
  validates_presence_of :commercial,              :if => :commercial_id
  validates_presence_of :creator,                 :if => :user_id
  validates_presence_of :approaching,             :if => :approaching_id
  validates_presence_of :order_type_id,           :if => :society_activity_sector
  validates_presence_of :order_type,              :if => :order_type_id
  
  validates_associated :customer, :ship_to_addresses, :end_products, :quotes #TODO quotes is really necessary ?
  
  validate :validates_length_of_ship_to_addresses
  validate :validates_order_type_validity
  #TODO validates_date :previsional_delivery (check if the date is correct, if it's after order creation date), etc. )
  
  journalize :identifier_method => Proc.new {|o| "#{o.title} - #{o.reference}"}
  
  has_search_index :only_attributes    => [ :title, :reference, :customer_needs ],
                   :only_relationships => [ :customer ]
  
  before_validation_on_create :update_reference
  
  after_save    :save_ship_to_addresses, :save_ship_to_addresses_from_new_establishments
  after_create  :create_steps
  
  # level constants
  CRITICAL  = 'critical'
  LATE      = 'late'
  TODAY     = 'today'
  SOON      = 'soon'
  FAR       = 'far'
  
  #TODO test this method
  def ready_to_deliver_end_products_and_quantities
    if production_step and production_step.manufacturing_step
      production_step.manufacturing_step.ready_to_deliver_end_products_and_quantities
    else
      []
    end
  end
  
  # return all delivery_notes with an active invoice
  # delivery_notes_with_invoice
  def billed_delivery_notes
    signed_delivery_notes.select{ |dn| dn.billed? }
  end
  
  # return all delivery_notes with an active and confirmed invoice
  # delivery_notes_with_confirmed_invoice
  def confirmed_billed_delivery_notes
    signed_delivery_note.select{ |dn| dn.billed_and_confirmed? }
  end
  
  # return all delivery_notes without active invoice, and with at least 1 delivered product
  # delivery_notes_without_invoice
  def unbilled_delivery_notes
    signed_delivery_notes.select{ |dn| !dn.billed? and dn.number_of_delivered_pieces > 0 }
  end
  
  # return all delivery_notes without active and confirmed invoice, and with at least 1 delivered product
  def delivery_notes_without_confirmed_invoice
    signed_delivery_notes.select{ |dn| !dn.billed_and_confirmed? and dn.number_of_delivered_pieces > 0 }
  end
  
  def all_is_delivered_or_scheduled?
    return false if delivery_notes.actives.empty? or signed_quote.nil?
    delivery_notes.actives.collect{ |dn| dn.number_of_delivered_pieces }.sum == signed_quote.number_of_pieces
  end
  
  def all_is_delivered?
    return false if signed_delivery_notes.empty? or signed_quote.nil?
    signed_delivery_notes.collect{ |dn| dn.number_of_delivered_pieces }.sum == signed_quote.number_of_pieces
  end
  
  def all_signed_delivery_notes_are_billed?
    return false if signed_delivery_notes.empty?
    unbilled_delivery_notes.empty?
  end
  
  def deposit_invoice
    invoices.first(:include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::DEPOSITE_INVOICE ])
  end
  
  def status_invoices
    invoices.find(:all, :include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::STATUS_INVOICE ])
  end
  
  def balance_invoices
    invoices.find(:all, :include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::BALANCE_INVOICE ])
  end
  
  def asset_invoices
    invoices.find(:all, :include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::ASSET_INVOICE ])
  end
  
  #TODO test this method
  def paid_amount
    invoices.paid.collect(&:already_paid_amount).sum
  end
  
  #TODO test this method
  def unpaid_amount
    signed_quote.total_with_taxes - paid_amount
  end
  
  #TODO test this method
  def billed_amount
    invoices.actives.collect(&:net_to_paid).sum
  end
  
  #TODO test this method
  def unbilled_amount
    signed_quote.total_with_taxes - billed_amount
  end
  
  def build_delivery_note_with_remaining_end_products_to_deliver
    return if all_is_delivered_or_scheduled?
    
    dn = delivery_notes.build
    signed_quote.end_products.each do |end_product|
      next unless end_product.remaining_quantity_to_deliver > 0
      dn.delivery_note_items.build(:order_id        => self.id,
                                   :end_product_id  => end_product.id,
                                   :quantity        => end_product.remaining_quantity_to_deliver)
    end
    
    return dn
  end
  
  def build_deposit_invoice_from_signed_quote
    return unless signed_quote
    
    invoice = invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::DEPOSITE_INVOICE).id)
    
    invoice.deposit         = signed_quote.deposit
    invoice.deposit_amount  = invoice.calculate_deposit_amount_according_to_quote_and_deposit
    invoice.deposit_vat     = ConfigurationManager.sales_deposit_tax_coefficient.to_f
    
    invoice.build_or_update_free_item_for_deposit_invoice
    
    return invoice
  end
  
  # +invoice_type_name+ may be +Invoice::STATUS_INVOICE+ or +Invoice::BALANCE_INVOICE+
  def build_invoice_from(delivery_notes, invoice_type_name)
    return if delivery_notes.empty? or !delivery_notes.select(&:new_record?).empty?
    
    invoice = invoices.build(:invoice_type_id => InvoiceType.find_by_name(invoice_type_name).id)
    
    for delivery_note in delivery_notes
      invoice.delivery_note_invoices.build(:delivery_note_id => delivery_note.id)
    end
    
    invoice.build_or_update_invoice_items_from_associated_delivery_notes
    
    return invoice
  end
  
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
  #     quote_step
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
  #     quote_step
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
  
  def all_end_products_have_signed_press_proof?
    end_products_without_signed_press_proof.empty?
  end
  
  def end_products_without_signed_press_proof
    end_products.reject{ |p| p.has_signed_press_proof? }
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
  
  #delegate :contacts, :to => :customer, :prefix => true, :allow_nil => true #TODO uncomment this line once we have migrated to rails 2.3.2
  def customer_contacts
    customer ? customer.contacts : []
  end
  
  def all_contacts_and_customer_contacts
    ( all_contacts + ( customer_contacts || [] ) ).uniq
  end
  
  #delegate :establishments, :to => :customer, :prefix => true, :allow_nil => true #TODO uncomment this line once we have migrated to rails 2.3.2
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
                                            #:parallel_creation  => true,
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
    all_ship_to_addresses = ship_to_addresses || []
    all_ship_to_addresses += customer.establishments.select(&:new_record?).collect(&:ship_to_addresses).flatten if customer
    if all_ship_to_addresses.select{ |s| (s.new_record? and s.should_create?) or (!s.new_record? and !s.should_destroy?) }.empty?
      errors.add(:ship_to_address_ids, "Vous devez choisir au moins 1 adresse de livraison")
    end
  end
  
  def create_missing_steps
    create_steps
  end
  
  private
#    def default_step
#      Step.find_by_name("commercial_step")
#    end
    
    # Create all orders_steps after create order
    def validates_order_type_validity
      if order_type and society_activity_sector
        errors.add(:order_type_id, I18n.t('activerecord.errors.messages.inclusion')) unless society_activity_sector.order_types.include?(order_type)
      end
    end
    
    def create_steps
      steps.each do |step|
        if step.parent.nil?
          step.name.camelize.constantize.find_or_create_by_order_id(self.id)
        else
          begin
            step_model        = step.name.camelize.constantize        # eg: SurveyStep
            parent_step_model = step.parent.name.camelize.constantize # eg: CommercialStep
            step_model.send("find_or_create_by_#{parent_step_model.table_name.singularize}_id", self.send(step.parent.name).id)
          rescue NameError => e
            error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
            RAKE_TASK ? puts(error) : raise(e)
          end
        end
      end
      
      activate_first_step
    end
    
    def activate_first_step
      first_level_steps.first.pending!
    end
    
    # that method permits to bound the new contact with the customer of the order.
    # after that, the contact which is first created for the customer, is associated to the order in a second time
#    def save_contacts_with_order_support
#      contacts.each do |contact|
#        unless customer.contacts.include?(contact)
#          customer.contacts << contact
#        end
#      end
#      
#      save_contacts_without_order_support
#    end
#    
#    alias_method_chain :save_contacts, :order_support
end
