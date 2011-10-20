## DATABASE STRUCTURE
# A integer  "order_id"
# A integer  "send_quote_method_id"
# A integer  "order_form_type_id"
# A integer  "quote_contact_id"
# A string   "status"
# A string   "reference"
# A float    "carriage_costs",          :default => 0.0
# A float    "prizegiving",             :default => 0.0
# A float    "deposit",                 :default => 0.0
# A text     "sales_terms"
# A string   "validity_delay_unit"
# A integer  "validity_delay"
# A string   "order_form_file_name"
# A string   "order_form_content_type"
# A integer  "order_form_file_size"
# A date     "published_on"
# A date     "sended_on"
# A date     "signed_on"
# A datetime "confirmed_at"
# A datetime "cancelled_at"
# A datetime "created_at"
# A datetime "updated_at"

class Quote < ActiveRecord::Base
  STATUS_CONFIRMED  = 'confirmed'
  STATUS_CANCELLED  = 'cancelled'
  STATUS_SENDED     = 'sended'
  STATUS_SIGNED     = 'signed'
  
  #TODO review that array (I18n)
  VALIDITY_DELAY_UNITS = { 'heures' => 'hours',
                           'jours'  => 'days',
                           'mois'   => 'months' }
  
  # priorities based on validity_date, published_on and dunnings
  LOW_PRIORITY    = 'low_priority'
  MEDIUM_PRIORITY = 'medium_priority'
  HIGH_PRIORITY   = 'high_priority'
  
  # define available quotable types, and their associated reference object
  QUOTABLES_REFERENCES = { "EndProduct" => "ProductReference",
                           "OrdersServiceDelivery" => "ServiceDelivery" }
  
  has_permissions :as_business_object, :additional_class_methods => [:confirm, :cancel, :send_to_customer, :sign]
  has_address     :bill_to_address
  has_address     :ship_to_address
  has_contact     :quote_contact, :accept_from => :order_and_customer_contacts, :required => true
  has_reference   :symbols => [:order], :prefix => :sales
  
  belongs_to :order
  belongs_to :commercial_actor, :class_name => 'Employee'
  belongs_to :send_quote_method
  belongs_to :order_form_type
  
  has_many :quote_items, :order => 'position', :dependent => :delete_all # not :destroy to avoid after_destroy is called in quote_item.rb
  
  has_attached_file :order_form,
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => '/quotes/:quote_id/order_form'
                    
  named_scope :actives, :conditions => [ 'status IS NULL OR status != ?', STATUS_CANCELLED ], :order => "quotes.created_at DESC"
  
  named_scope :pending,   :conditions => [ 'status IN (?)', [STATUS_CONFIRMED, STATUS_SENDED] ], :order => "quotes.created_at DESC"
  named_scope :unsigned,  :conditions => [ 'status IS NULL OR status IN (?)', [STATUS_CONFIRMED, STATUS_SENDED] ], :order => "quotes.created_at DESC"
  named_scope :signed,    :conditions => [ 'status = ?', STATUS_SIGNED ], :order => "quotes.created_at DESC"
  
  validates_associated :quote_items
  
  # when quote is UNSAVED
  with_options :if => :new_record? do |x|
    x.validates_inclusion_of :status, :in => [ nil ]
  end
  
  # when quote is UNCOMPLETE
  with_options :if => :was_uncomplete? do |x|
    x.validates_inclusion_of :status, :in => [ nil, STATUS_CONFIRMED ]
    x.validates_persistence_of :order_id
  end
  
  # when quote is UNSAVED or UNCOMPLETE
  with_options :if => Proc.new{ |quote| quote.new_record? or quote.was_uncomplete? } do |x|
    x.validates_presence_of :order_id, :commercial_actor_id
    x.validates_presence_of :order,             :if => :order_id
    x.validates_presence_of :commercial_actor,  :if => :commercial_actor_id
    
    x.validates_numericality_of :prizegiving, :carriage_costs, :deposit, :validity_delay
    
    x.validates_inclusion_of :validity_delay_unit, :in => VALIDITY_DELAY_UNITS.values
    
    x.validate :validates_length_of_quote_items
  end
  
  # when quote is UNCOMPLETE and above
  with_options :if => :created_at_was do |x|
    # nothing...
  end
  
  ### while quote CONFIRMATION
  with_options :if => Proc.new{ |quote| quote.created_at_was and quote.confirmed? } do |x|
    x.validates_presence_of :confirmed_at, :published_on, :reference
    
    x.validates_date :confirmed_at, :on_or_after => :created_at
  end
  
  # when quote is CONFIRMED
  with_options :if => :was_confirmed? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_SENDED ]
  end
  
  # when quote is CONFIRMED and above
  with_options :if => :confirmed_at_was do |x|
    x.validates_persistence_of :confirmed_at, :published_on, :commercial_actor_id, :quote_contact_id, :carriage_costs,
                               :prizegiving, :deposit, :sales_terms, :validity_delay_unit, :validity_delay, :quote_items
  end
  
  ### while quote CANCELLATION
  with_options :if => Proc.new{ |quote| quote.confirmed_at_was and quote.cancelled? } do |x|
    x.validates_presence_of :cancelled_at
    x.validates_date :cancelled_at, :on_or_after         => :confirmed_at,
                                    :on_or_after_message => :message_for_validates_date_cancelled_at_on_or_after_while_confirmed
  end
  
  # when quote is CANCELLED
  with_options :if => :was_cancelled? do |x|
    x.validates_persistence_of :status, :cancelled_at
  end
  
  ### while quote SENDING
  with_options :if => Proc.new{ |quote| quote.confirmed_at_was and quote.sended? } do |x|
    x.validates_presence_of :sended_on, :send_quote_method_id
    x.validates_presence_of :send_quote_method, :if => :send_quote_method_id
    
    x.validates_date :sended_on,  :on_or_after  => :published_on
    x.validates_date :sended_on,  :on_or_before => Date.today
  end
  
  # when quote is SENT
  with_options :if => :was_sended? do |x|
    # nothing...
  end
  
  # when quote is SENT and above
  with_options :if => :sended_on_was do |x|
    x.validates_persistence_of :sended_on, :send_quote_method_id
  end
  
  ### while quote SIGNING
  with_options :if => Proc.new{ |quote| quote.sended_on_was and quote.signed? } do |x|
    x.validates_presence_of :order_form_type_id, :order_form
    x.validates_presence_of :order_form_type, :if => :order_form_type_id
    
    x.validates_date  :signed_on, :on_or_after  => :sended_on,
                                  :on_or_before => Date.today
    
    x.validate :validates_presence_of_order_form
  end
  
  # when quote is SIGNED
  with_options :if => :was_signed? do |x|
    x.validates_persistence_of :status  # we have to remove this line if we want to be able to cancel a signed quote
  end
  
  journalize :attributes   => [:reference, :status, :published_on, :sended_on, :signed_on, :confirmed_at, :cancelled_at,
                               :send_quote_method_id, :order_form_type_id, :commercial_actor_id, :quote_contact_id,
                               :carriage_costs, :prizegiving, :deposit, :sales_terms, :validity_delay, :validity_delay_unit],
             :subresources => [:quote_items, :bill_to_address, :ship_to_address],
             :attachments  =>  :order_form
  
  after_save    :save_quote_items
  after_save    :remove_order_end_products
  after_update  :update_quote_step_status
  
  has_search_index :only_attributes       => [ :confirmed_at, :cancelled_at, :created_at, :deposit, :published_on, :reference, :sended_on, :signed_on, :status, :validity_delay ],
                   :additional_attributes => { :validity_date => :date, :total_with_taxes => :float },
                   :only_relationships    => [ :commercial_actor, :order, :quote_contact, :send_quote_method ]
  
  active_counter :model => 'Order', :callbacks => { :in_progress_total    => :after_save,
                                                    :commercial_total     => :after_save,
                                                    :pre_invoicing_orders => :after_save,
                                                    :pre_invoicing_total  => :after_save }
  
  active_counter :counters  => { :pending_quotes  => :integer,
                                 :pending_total   => :float },
                 :callbacks => { :pending_quotes  => :after_save,
                                 :pending_total   => :after_save }
  
  attr_protected :status, :confirmed_at, :cancelled_at
  
  attr_accessor :order_end_products_to_remove
  
  def initialize(*params)
    super(*params)
    @order_end_products_to_remove ||= []
  end
  
  def after_find
    @order_end_products_to_remove ||= []
  end
  
  def validates_presence_of_order_form # the method validates_attachment_presence of paperclip seems to be broken when using conditions
    if order_form.nil? or order_form.instance.order_form_file_name.blank? or order_form.instance.order_form_file_size.blank? or order_form.instance.order_form_content_type.blank?
      errors.add(:order_form, "est requis")
    end
  end
  
  def validates_length_of_quote_items
    if quote_items.reject(&:free_item?).reject(&:should_destroy?).empty?
      errors.add(:quote_item_ids, "Vous devez entrer au moins 1 produit ou 1 prestation")
    end
  end
  
  def prizegiving
    self[:prizegiving] ||= 0.0
  end
  
  def carriage_costs
    self[:carriage_costs] ||= 0.0
  end
  
  def free_quote_items
    quote_items.select(&:free_item?)
  end
  
  def product_quote_items
    quote_items.select(&:product_item?)
  end
  
  def service_quote_items
    quote_items.select(&:service_item?)
  end
  
  def sorted_quote_items
    quote_items.sort_by(&:position)
  end
  
  def quotables
    quote_items.collect(&:quotable).compact
  end
  
  def end_products
    product_quote_items.collect(&:quotable)
  end
  
  def orders_service_deliveries
    service_quote_items.collect(&:quotable)
  end
  
  #TODO test this method
  def missing_end_products
    order.end_products - end_products
  end
  
  #TODO test this method
  def missing_orders_service_deliveries
    order.orders_service_deliveries - orders_service_deliveries
  end
  
  #TODO test this method
  def excess_product_quote_items
    product_quote_items.reject(&:quotable)
  end
  
  #TODO test this method
  def excess_service_quote_items
    service_quote_items.reject(&:quotable)
  end
  
  def build_quote_item(quote_item_attributes)
    raise ArgumentError, "build_quote_item expected to receive :quotable_type and :quotable_id OR :reference_object_type and :reference_object_id in parameter" if ( quote_item_attributes[:reference_object_id].blank? or quote_item_attributes[:reference_object_type].blank? ) and ( quote_item_attributes[:quotable_type].blank? or quote_item_attributes[:quotable_id].blank? )
    
    if quote_item_attributes[:quotable_type] # EndProduct or OrdersServiceDelivery
      quotable = quote_item_attributes[:quotable_type].constantize.find_by_id(quote_item_attributes[:quotable_id])
    elsif quote_item_attributes[:reference_object_type] # ProductReference or ServiceDelivery
      quotable = quote_item_attributes[:reference_object_type].constantize.find_by_id(quote_item_attributes[:reference_object_id])
    end
    
    name        = quotable.name
    description = quotable.description
    width       = quotable.width rescue nil # OrdersServiceDelivery doesn't have width
    length      = quotable.length rescue nil # OrdersServiceDelivery doesn't have length
    height      = quotable.height rescue nil # OrdersServiceDelivery doesn't have height
    quantity    = quotable.quantity rescue nil # ProductReference doesn't have quantity
    unit_price  = quotable.unit_price
    prizegiving = quotable.prizegiving
    vat         = quotable.vat || ( product.product_reference.vat rescue nil )
    
    reference_object_type, reference_object_id = nil, nil
    
    if quote_item_attributes[:quotable_type] == "EndProduct"
      reference_object_type = "ProductReference"
      reference_object_id = quote_item_attributes[:reference_object_id] || quotable.product_reference.id
    elsif quote_item_attributes[:quotable_type] == "OrdersServiceDelivery"
      reference_object_type = "ServiceDelivery"
      reference_object_id = quote_item_attributes[:reference_object_id] || quotable.service_delivery.id
    end
    
    quote_item_attributes = { :reference_object_type  => reference_object_type,
                              :reference_object_id    => reference_object_id,
                              :name                   => name,
                              :description            => description,
                              :width                  => width,
                              :length                 => length,
                              :height                 => height,
                              :unit_price             => unit_price,
                              :prizegiving            => prizegiving,
                              :quantity               => quantity,
                              :vat                    => vat
                            }.merge(quote_item_attributes)
    
    build_or_update_quote_item(quote_item_attributes)
  end
  
  def product_quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      build_or_update_quote_item(attributes)
    end
    
    # automatically remove a end_product from order if quote_items do not include this end_product
    #TODO not sure if that's alright... we should remove (or deactivate) non-present end_products, but only when the quote is signed!
    #     that was OK when we authorized to create 1 quote at time... but we will permit to create multiple quotes at time soon!
    #     so that code will need to be removed
    order.end_products.reject(&:new_record?).each do |p|
      @order_end_products_to_remove << p unless product_quote_items.collect(&:quotable_id).include?(p.id)
    end
  end
  
  def service_quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      build_or_update_quote_item(attributes)
    end
  end
  
  def free_quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      build_or_update_quote_item(attributes) unless attributes[:name].blank? and attributes[:description].blank? and attributes[:width].blank? and attributes[:length].blank? and attributes[:height].blank? and attributes[:unit_price].blank? and attributes[:prizegiving].blank? and attributes[:quantity].blank? and attributes[:vat].blank?
    end
  end
  
  def save_quote_items
    quote_items.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end
  
  def remove_order_end_products
    @order_end_products_to_remove.each(&:destroy)
  end
  
  #TODO test this method
  def total
    (product_quote_items + service_quote_items).collect(&:total).sum
  end
  
  def net
    prizegiving = self.prizegiving || 0.0
    total * ( 1 - ( prizegiving / 100 ) )
  end
  
  #TODO test this method
  def total_with_taxes
    (product_quote_items + service_quote_items).collect(&:total_with_taxes).sum
  end
  
  def summon_of_taxes
    #total_with_taxes - total
    (product_quote_items + service_quote_items).collect(&:taxes).sum
  end
  
  def net_to_paid
    carriage_costs = self.carriage_costs || 0.0
    net + carriage_costs + summon_of_taxes
  end
  
  #TODO test this method
  def tax_coefficients
    (product_quote_items + service_quote_items).collect(&:vat).uniq
  end
  
  #TODO test this method
  def total_taxes_for(coefficient)
    (product_quote_items + service_quote_items).select{ |i| i.vat == coefficient }.collect(&:total).sum
  end
  
  def number_of_pieces
    product_quote_items.collect(&:quantity).compact.sum
  end
  
  def number_of_products
    product_quote_items.count
  end
  
  #TODO test this method
  def number_of_services
    service_quote_items.count
  end
  
  def confirm
    if can_be_confirmed?
      update_reference
      self.published_on ||= Date.today
      self.confirmed_at   = Time.zone.now
      self.status         = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.zone.now
      self.status       = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
  def send_to_customer(attributes)
    if can_be_sended?
      self.attributes = attributes
      self.status     = STATUS_SENDED
      self.save
  else
      false
    end
  end
  
  def sign(attributes)
    if can_be_signed?
      self.attributes = attributes
      self.status     = STATUS_SIGNED
      self.save
    else
      false
    end
  end
  
  #TODO test this method
  def quote_step_open?
    order && order.commercial_step && order.commercial_step.quote_step && !order.commercial_step.quote_step.terminated?
  end
  
  # quote is considered as 'uncomplete' if its status is nil
  def uncomplete?
    status.nil?
  end
  
  def confirmed?
    status == STATUS_CONFIRMED
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def sended?
    status == STATUS_SENDED
  end
  
  def signed?
    status == STATUS_SIGNED
  end
  
  def was_uncomplete?
    status_was.nil?
  end
  
  def was_confirmed?
    status_was == STATUS_CONFIRMED
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def was_sended?
    status_was == STATUS_SENDED
  end
  
  def was_signed?
    status_was == STATUS_SIGNED
  end
  
  def validity_date
    return unless published_on and validity_delay_unit and validity_delay
    published_on + validity_delay.send(validity_delay_unit)
  end
  
  def can_be_added?
    #TODO this method should be reviewed because we will need to authorize user to create many quotes at the same time
    quote_step_open? and order.draft_quote(true).nil? and order.pending_quote(true).nil? and order.signed_quote(true).nil?
  end
  
  def can_be_edited? # we don't choose 'can_edit?' to avoid conflict with 'has_permissions' methods
    !new_record? and was_uncomplete? and quote_step_open?
  end
  
  def can_be_downloaded? # with PDF generator
    reference_was
  end
  
  def can_be_deleted?
    !new_record? and was_uncomplete? and quote_step_open?
  end
  
  def can_be_confirmed?
    #TODO this method should be reviewed because we will need to authorize user to confirm many quotes at the same time
    !new_record? and was_uncomplete? and quote_step_open? and order.pending_quote(true).nil? and order.signed_quote(true).nil?
  end
  
  def can_be_cancelled?
    !new_record? and ( was_uncomplete? or was_confirmed? or was_sended? ) and quote_step_open?
  end
  
  def can_be_sended?
    was_confirmed? and quote_step_open?
  end
  
  def can_be_signed?
    was_sended? and order.signed_quote(true).nil? and quote_step_open?
  end
  
  def order_and_customer_contacts
    order ? order.all_contacts_and_customer_contacts : []
  end
  
  def priority_level #TODO priority_level should take in account the dunnings
    return unless validity_date
    
    now             = Time.zone.now.to_datetime
    expiration_date = validity_date.to_datetime
    half_date       = (expiration_date - (validity_delay / 2).days).to_datetime
    
    return LOW_PRIORITY    if now <= half_date
    return MEDIUM_PRIORITY if now > half_date and now < expiration_date
    return HIGH_PRIORITY   if now >= expiration_date
  end
  
  class << self
    def pending_quotes_counter # @override (active_counter)
      Quote.pending.count
    end
    
    def pending_total_counter # @override (active_counter)
      Quote.pending.collect(&:total_with_taxes).compact.sum
    end
  end
  
  private
    def update_quote_step_status
      if signed?
        order.commercial_step.quote_step.terminated!
        if deposit > 0
          order.invoicing_step.pending!
          order.invoicing_step.invoice_step.pending!
        end
      end
    end
    
    def build_or_update_quote_item(quote_item_attributes)
      attributes = quote_item_attributes.merge(:order_id => order_id)
      
      if attributes[:id].blank?
        quote_item = quote_items.build(attributes)
      else
        quote_item = quote_items.detect { |x| x.id == attributes[:id].to_i }
        quote_item.attributes = attributes
      end
      
      return quote_item
    end
end
