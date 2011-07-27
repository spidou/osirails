## DATABASE STRUCTURE
# A integer  "commercial_id"
# A integer  "user_id"
# A integer  "customer_id"
# A integer  "order_type_id"
# A integer  "approaching_id"
# A integer  "order_contact_id"
# A string   "title"
# A string   "reference"
# A text     "customer_needs"
# A date     "previsional_delivery"
# A date     "quotation_deadline"
# A integer  "delivery_time"
# A datetime "created_at"
# A datetime "updated_at"
# A string   "status"
# A date     "standby_on"
# A date     "discarded_on"
# A date     "completed_on"

class Order < ActiveRecord::Base
  STATUS_PENDING    = 'pending'
  STATUS_STANDBY    = 'standby'
  STATUS_DISCARDED  = 'discarded'
  STATUS_COMPLETED  = 'completed'
  
  has_permissions :as_business_object
  has_address     :bill_to_address
  has_contact     :order_contact, :accept_from => :customer_contacts, :required => true
  has_reference   :prefix => :sales
  
  belongs_to :order_type
  belongs_to :customer
  belongs_to :commercial, :class_name => 'Employee'
  belongs_to :creator,    :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :approaching
  
  # steps
  has_one :commercial_step
  has_one :production_step
  has_one :delivering_step
  has_one :invoicing_step
  
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
  has_many :signed_delivery_notes,      :class_name => 'DeliveryNote', :conditions => [ "status = ?", DeliveryNote::STATUS_SIGNED ], :order => "created_at DESC" #OPTIMIZE shouldn't we use named_scope on DeliveryNote instead ? (order.delivery_notes.signed)
  
  # invoices
  has_many :invoices, :order => 'invoices.created_at DESC'
  
  has_many :ship_to_addresses
  has_many :order_logs
  has_many :mockups
  has_many :graphic_documents
  
  has_many :end_products,               :conditions => [ 'cancelled_at IS NULL' ]
  has_many :orders_service_deliveries,  :conditions => [ 'cancelled_at IS NULL' ]
  has_many :service_deliveries, :through => :orders_service_deliveries
  
  has_many :disabled_end_products,              :class_name => 'EndProduct',            :conditions => [ 'cancelled_at IS NOT NULL' ]
  has_many :disabled_orders_service_deliveries, :class_name => 'OrdersServiceDelivery', :conditions => [ 'cancelled_at IS NOT NULL' ]
  
  named_scope :pending,   :conditions => [ "orders.status = ?", STATUS_PENDING ]
  named_scope :standby,   :conditions => [ "orders.status = ?", STATUS_STANDBY ]
  named_scope :discarded, :conditions => [ "orders.status = ?", STATUS_DISCARDED ]
  named_scope :completed, :conditions => [ "orders.status = ?", STATUS_COMPLETED ]
  named_scope :closed,    :conditions => [ "orders.status <> ?", STATUS_PENDING ]
  
  named_scope :in_commercial_step, :include => :commercial_step, :conditions => [ "commercial_steps.status IN (?)", ['pending', 'in_progress'] ]
  named_scope :in_production_step, :include => :production_step, :conditions => [ "production_steps.status IN (?)", ['pending', 'in_progress'] ]
  named_scope :in_delivering_step, :include => :delivering_step, :conditions => [ "delivering_steps.status IN (?)", ['pending', 'in_progress'] ]
  #named_scope :in_pre_invoicing_step, :include => :invoicing_step, :conditions => [ "invoicing_steps.status IN (?) AND billable_amount > 0", ['pending', 'in_progress'] ]
  named_scope :in_invoicing_step, :include => :invoicing_step, :conditions => [ "invoicing_steps.status IN (?)", ['pending', 'in_progress'] ]
  
  validates_presence_of :reference, :title, :previsional_delivery, :customer_needs, :bill_to_address
  validates_presence_of :customer_id, :commercial_id, :user_id, :approaching_id, :order_type_id
  validates_presence_of :customer,    :if => :customer_id
  validates_presence_of :commercial,  :if => :commercial_id
  validates_presence_of :creator,     :if => :user_id
  validates_presence_of :approaching, :if => :approaching_id
  validates_presence_of :order_type,  :if => :order_type_id
  
  validates_presence_of :standby_on,   :if => :standby?
  validates_presence_of :discarded_on, :if => :discarded?
  validates_presence_of :completed_on, :if => :completed?
  
  validates_inclusion_of :status, :in => [ STATUS_PENDING, STATUS_STANDBY, STATUS_DISCARDED, STATUS_COMPLETED ]
  
  validates_associated :customer, :ship_to_addresses, :end_products
  
  validate :validates_length_of_ship_to_addresses
  #TODO validates_date :previsional_delivery (check if the date is correct, if it's after order creation date), etc. )
  
  journalize :attributes        => [ :status, :user_id, :commercial_id, :customer_id, :order_type_id, :approaching_id,
                                     :order_contact_id, :title, :reference, :customer_needs, :previsional_delivery, :quotation_deadline],
             :identifier_method => Proc.new {|o| "#{o.title} - #{o.reference}"}
  
  has_search_index :only_attributes       => [ :status, :reference, :title, :customer_needs, :previsional_delivery, :quotation_deadline,
                                               :created_at, :standby_on, :discarded_on, :completed_on ],
                   :additional_attributes => { :brand_names => :string,
                                               :deposit_invoice_status => :string,
                                               :amount => :float,
                                               :ready_to_deliver_pieces => :integer,
                                               :delivered_pieces => :integer,
                                               :billable_amount => :float,
                                               :billed_amount => :float,
                                               :unbilled_amount => :float,
                                               :paid_amount => :float,
                                               :unpaid_amount => :float,
                                               :status_since => :date },
                   :only_relationships    => [ :customer, :commercial, :order_type, :ship_to_addresses, :approaching,
                                               :commercial_step, :production_step, :delivering_step, :invoicing_step, :signed_quote ]
  
  before_validation_on_create :update_reference
  before_validation_on_update :update_status_dates
  
  after_save    :save_ship_to_addresses, :save_ship_to_addresses_from_new_establishments
  after_create  :create_steps
  
  active_counter :counters  => { :in_progress_orders    => :integer, :in_progress_total   => :float,
                                 :commercial_orders     => :integer, :commercial_total    => :float,
                                 :production_orders     => :integer, :production_total    => :float,
                                 :delivering_orders     => :integer, :delivering_total    => :float,
                                 :pre_invoicing_orders  => :integer, :pre_invoicing_total => :float,
                                 :invoicing_orders      => :integer, :invoicing_total     => :float },
                 :callbacks => { :in_progress_orders  => :after_save,
                                 :in_progress_total   => :after_save,
                                 :commercial_orders   => :after_save,
                                 :commercial_total    => :after_save }
  
  # level constants
  CRITICAL  = 'critical'
  LATE      = 'late'
  TODAY     = 'today'
  SOON      = 'soon'
  FAR       = 'far'
  
  def status
    self[:status] ||= STATUS_PENDING
  end
  
  def pending?
    status == STATUS_PENDING
  end
  
  def standby?
    status == STATUS_STANDBY
  end
  
  def discarded?
    status == STATUS_DISCARDED
  end
  
  def completed?
    status == STATUS_COMPLETED
  end
  
  def complete!
    self.status = STATUS_COMPLETED
    self.save
  end
  
  def status_since #TODO use journalization to get dates
    if pending?
      created_at
    elsif standby?
      standby_on
    elsif discarded?
      discarded_on
    elsif completed?
      completed_on
    end
  end
  
  #TODO test this method
  def ready_to_deliver_end_products_and_quantities
    if production_step and production_step.manufacturing_step
      production_step.manufacturing_step.ready_to_deliver_end_products_and_quantities
    else
      []
    end
  end
  
  def ready_to_deliver_pieces
    ready_to_deliver_end_products_and_quantities.collect{ |h| h[:quantity] }.sum
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
  
  # return all orders_service_deliveries which are not used on a confirmed invoice
  def orders_service_deliveries_without_confirmed_invoice
    orders_service_deliveries.reject{ |osd| osd.billed_and_confirmed? }
  end
  
  def all_is_delivered_or_scheduled?
    return false if signed_quote.nil? or delivery_notes.actives.empty?
    delivery_notes.actives.collect{ |dn| dn.number_of_delivered_pieces }.sum == signed_quote.number_of_pieces
  end
  
  def all_is_delivered?
    return false if signed_quote.nil? or signed_delivery_notes.empty?
    signed_delivery_notes.collect{ |dn| dn.number_of_delivered_pieces }.sum == signed_quote.number_of_pieces
  end
  
  def all_signed_delivery_notes_are_billed?
    signed_delivery_notes.any? and unbilled_delivery_notes.empty?
  end
  
  def all_signed_delivery_notes_have_confirmed_invoice?
    signed_delivery_notes.any? and delivery_notes_without_confirmed_invoice.empty?
  end
  
  def delivered_pieces
    signed_delivery_notes.collect(&:number_of_pieces).sum 
  end
  
  def deposit_invoice(force_reload = false)
    @deposit_invoice = nil if force_reload
    @deposit_invoice ||= invoices.first(:include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::DEPOSITE_INVOICE ])
  end
  
  def status_invoices(force_reload = false)
    @status_invoices = nil if force_reload
    @status_invoices ||= invoices.find(:all, :include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::STATUS_INVOICE ])
  end
  
  def balance_invoice(force_reload = false)
    @balance_invoice = nil if force_reload
    @balance_invoice ||= invoices.first(:include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::BALANCE_INVOICE ])
  end
  
  def asset_invoices(force_reload = false)
    @asset_invoices = nil if force_reload
    @asset_invoices ||= invoices.find(:all, :include => [:invoice_type], :conditions => [ '(status IS NULL OR status != ?) AND invoice_types.name = ?', Invoice::STATUS_CANCELLED, Invoice::ASSET_INVOICE ])
  end
  
  def signed_amount
    signed_quote && signed_quote.total_with_taxes
  end
  
  #TODO test this method
  def billable_amount(force_reload = false)
    @billable_amount = nil if force_reload
    if @billable_amount.nil?
      @billable_amount = 0
      @billable_amount += delivery_notes_without_confirmed_invoice.collect(&:total_with_taxes).sum
      if deposit_required? and ( deposit_invoice.nil? or deposit_invoice.confirmed_at_was.nil? )
        @billable_amount += signed_amount * signed_quote.deposit / 100
      elsif deposit_invoice and deposit_invoice.confirmed_at_was
        @billable_amount -= deposit_invoice.total_with_taxes
      end
      #@billable_amount = signed_amount if @billable_amount > signed_amount
    end
    @billable_amount
  end
  
  #TODO test this method
  def billed_amount(force_reload = false)
    @billed_amount = nil if force_reload
    @billed_amount ||= invoices(force_reload).billed.collect(&:net_to_paid).sum
  end
  
  #TODO test this method
  def unbilled_amount(force_reload = false)
    if force_reload
      @unbilled_amount = nil
      @billed_amount = nil
    end
    @unbilled_amount ||= ( signed_quote(force_reload) && ( signed_quote.total_with_taxes - billed_amount ) )
  end
  
  #TODO test this method
  def paid_amount(force_reload = false)
    @paid_amount = nil if force_reload
    @paid_amount ||= invoices(force_reload).paid.collect(&:already_paid_amount).sum
  end
  
  #TODO test this method
  def unpaid_amount(force_reload = false)
    if force_reload
      @unpaid_amount = nil
      @billed_amount = nil
      @paid_amount = nil
    end
    #@unpaid_amount ||= ( billed_amount.to_f.round_to(2) - paid_amount.to_f.round_to(2) ) # without 'round_to', the 2 values can be different with very very small variation (eg: 7.27595761418343e-12)
    @unpaid_amount ||= ( billed_amount - paid_amount )
  end
  
  def build_delivery_note_with_remaining_end_products_to_deliver
    return if all_is_delivered_or_scheduled?
    
    dn = delivery_notes.build
    dn.build_delivery_note_items_from_remaining_quantity_of_end_products_to_deliver
    
    return dn
  end
  
  def build_deposit_invoice_from_signed_quote
    return unless signed_quote
    
    invoice = invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::DEPOSITE_INVOICE).id)
    
    invoice.deposit         = signed_quote.deposit
    invoice.deposit_amount  = invoice.calculate_deposit_amount_according_to_quote_and_deposit
    invoice.deposit_vat     = ConfigurationManager.sales_deposit_tax_coefficient.to_f
    
    invoice.build_or_update_free_invoice_item_for_deposit_invoice
    
    return invoice
  end
  
  # +invoice_type_name+ may be +Invoice::STATUS_INVOICE+ or +Invoice::BALANCE_INVOICE+
  def build_invoice_from(delivery_notes, invoice_type_name)
    invoice = invoices.build(:invoice_type_id => InvoiceType.find_by_name(invoice_type_name).id)
    
    for delivery_note in delivery_notes.reject(&:new_record?)
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
    steps.reject(&:parent).sort_by(&:position).collect{ |step| send(step.name) }
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
  
  def brand_names
    ship_to_addresses.collect(&:establishment_name).join(', ') #TODO really used?
  end
  
  def amount # return amount of quote (signed or not)
    ( quote = (signed_quote || pending_quote || draft_quote) ) && quote.total_with_taxes
  end
  
  def deposit_invoice_status
    deposit_invoice && deposit_invoice.status
  end
  
  def deposit_required?
    signed_quote && signed_quote.deposit > 0
  end
  
  class << self
    def in_progress_orders_counter # @override (active_counter)
      Order.pending.count
    end
    
    def commercial_orders_counter # @override (active_counter)
      Order.pending.in_commercial_step.count
    end
    
    def production_orders_counter # @override (active_counter)
      Order.pending.in_production_step.count
    end
    
    def delivering_orders_counter # @override (active_counter)
      Order.pending.in_delivering_step.count
    end
    
    def pre_invoicing_orders_counter # @override (active_counter)
      Order.search_with('status' => {:value => 'pending', :action => '='}, 'invoicing_step.status' => {:value => 'pending,in_progress', :action => '='}, 'billable_amount' => {:value => '0', :action => '>'}).count
    end
    
    def invoicing_orders_counter # @override (active_counter)
      Order.search_with('status' => {:value => 'pending', :action => '='}, 'invoicing_step.status' => {:value => 'pending,in_progress', :action => '='}, 'billed_amount' => {:value => '0', :action => '>'}, 'unpaid_amount' => {:value => '0', :action => '>'}).count
    end
    
    def in_progress_total_counter # @override (active_counter)
      Order.pending.collect(&:signed_amount).compact.sum
    end
    
    def commercial_total_counter # @override (active_counter)
      #TODO get also orders with unsigned orders (instead of getting only signed ones)
      Order.pending.in_commercial_step.collect(&:signed_amount).compact.sum
    end
    
    def production_total_counter # @override (active_counter)
      Order.pending.in_production_step.collect(&:signed_amount).compact.sum
    end
    
    def delivering_total_counter # @override (active_counter)
      Order.pending.in_delivering_step.collect(&:signed_amount).compact.sum
    end
    
    def pre_invoicing_total_counter # @override (active_counter)
      Order.search_with('status' => {:value => 'pending', :action => '='}, 'invoicing_step.status' => {:value => 'pending,in_progress', :action => '='}, 'billable_amount' => {:value => '0', :action => '>'}).collect(&:billable_amount).compact.sum
    end
    
    def invoicing_total_counter # @override (active_counter)
      Order.search_with('status' => {:value => 'pending', :action => '='}, 'invoicing_step.status' => {:value => 'pending,in_progress', :action => '='}, 'billed_amount' => {:value => '0', :action => '>'}, 'unpaid_amount' => {:value => '0', :action => '>'}).collect(&:unpaid_amount).compact.sum
    end
  end
  
  private
#    def default_step
#      Step.find_by_name("commercial_step")
#    end
    
    # Create all orders_steps after create order
    def create_steps
      steps.each do |step|
        if step.parent.nil?
          new_step = step.name.camelize.constantize.find_or_create_by_order_id(self.id)
        else
          begin
            step_model        = step.name.camelize.constantize        # eg: SurveyStep
            parent_step_model = step.parent.name.camelize.constantize # eg: CommercialStep
            step_model.send("find_or_create_by_#{parent_step_model.table_name.singularize}_id", self.send(step.parent.name).id)
            
            new_step = step_model.send("find_or_create_by_#{parent_step_model.table_name.singularize}_id", self.send(step.parent.name).id)
          rescue NameError => e
            error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
            RAKE_TASK ? puts(error) : raise(e)
          end
        end
        
        raise Exception, "the new step '#{new_step.class}' should have been created successfully. Errors : #{new_step.errors.full_messages.join(', ')}" if new_step and new_step.new_record?
      end
      
      activate_first_step
    end
    
    def activate_first_step
      first_level_steps.first.pending!
    end
    
    def update_status_dates
      if changes["status"]
        if standby?
          self.standby_on = Time.zone.now
        elsif discarded?
          self.discarded_on = Time.zone.now
        elsif completed?
          self.completed_on = Time.zone.now
        end
      end
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
