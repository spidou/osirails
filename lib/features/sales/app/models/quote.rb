class Quote < ActiveRecord::Base
  STATUS_CONFIRMED  = 'confirmed'
  STATUS_CANCELLED  = 'cancelled'
  STATUS_SENDED     = 'sended'
  STATUS_SIGNED     = 'signed'
  
  VALIDITY_DELAY_UNITS = { 'heures' => 'hours',
                           'jours'  => 'days',
                           'mois'   => 'months' }
  
  has_permissions :as_business_object, :additional_class_methods => [:confirm, :cancel, :send_to_customer, :sign]
  has_address     :bill_to_address
  has_address     :ship_to_address
  has_contact     :accept_from => :order_contacts
  has_reference   :symbols => [:order], :prefix => :sales
  
  belongs_to :creator, :class_name => 'User'
  belongs_to :order
  belongs_to :send_quote_method
  belongs_to :order_form_type
  
  has_many :quote_items, :dependent => :delete_all # not :destroy to avoid after_destroy is called in quote_item.rb
  has_many :products, :through => :quote_items
  
  has_attached_file :order_form,
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url => '/quotes/:quote_id/order_form'
  
  validates_contact_presence
  
  validates_presence_of     :order_id, :creator_id
  validates_presence_of     :order,   :if => :order_id
  validates_presence_of     :creator, :if => :creator_id
  
  validates_numericality_of :reduction, :carriage_costs, :discount, :account, :validity_delay
  
  validates_inclusion_of    :validity_delay_unit, :in => VALIDITY_DELAY_UNITS.values
  validates_inclusion_of    :status, :in => [ STATUS_CONFIRMED, STATUS_CANCELLED, STATUS_SENDED, STATUS_SIGNED ], :allow_nil => true
  
  validates_associated      :quote_items, :products
  
  validate :validates_length_of_quote_items
  
  ## VALIDATIONS ON VALIDATING QUOTE
  with_options :if => :confirmed? do |quote|
    quote.validates_date :confirmed_on, :equal_to => Proc.new { Date.today }
    quote.validates_uniqueness_of :reference
  end
  
  ## VALIDATIONS ON INVALIDATING QUOTE
  validates_date :cancelled_on, :equal_to => Proc.new { Date.today }, :if => :cancelled?
  
  ## VALIDATIONS ON SENDING QUOTE
  with_options :if => :sended? do |quote|
    quote.validates_date  :sended_on,
                          :on_or_after  => :created_at, :on_or_after_message => "ne doit pas être AVANT la date de création du devis&#160;(%s)",
                          :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    
    quote.validates_presence_of :send_quote_method_id
    quote.validates_presence_of :send_quote_method, :if => :send_quote_method_id # prevent errors by providing wrong ID
  end
  
  ## VALIDATIONS ON SIGNING QUOTE
  with_options :if => :signed? do |quote|
    quote.validates_presence_of :order_form_type_id, :order_form
    quote.validates_presence_of :order_form_type, :if => :order_form_type_id
    
    quote.validates_date  :signed_on,
                          :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi du devis&#160;(%s)",
                          :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    
    quote.validate :validates_presence_of_order_form
  end
  
  after_save    :save_quote_items, :remove_order_products
  after_update  :update_estimate_step_status
  
  attr_protected :status, :reference, :confirmed_on, :cancelled_on, :sended_on, :send_quote_method_id,
                 :signed_on, :order_form_type_id, :order_form
  
  attr_accessor :order_products_to_remove
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:validity_delay]    = 'Période de validité :'
  @@form_labels[:sended_on]         = 'Devis envoyé au client le :'
  @@form_labels[:send_quote_method] = 'Par :'
  @@form_labels[:signed_on]         = 'Devis signé par le client le :'
  @@form_labels[:order_form_type]   = 'Type de document :'
  @@form_labels[:order_form]        = 'Fichier :'
  @@form_labels[:sales_terms]       = 'Conditions commerciales :'
  
  def initialize(*params)
    super(*params)
    @order_products_to_remove ||= []
  end
  
  def after_find
    @order_products_to_remove ||= []
  end
  
  def validates_presence_of_order_form # the method validates_attachment_presence of paperclip seems to be broken when using conditions
    if order_form.nil? or order_form.instance.order_form_file_name.blank? or order_form.instance.order_form_file_size.blank? or order_form.instance.order_form_content_type.blank?
      errors.add(:order_form, "est requis")
    end
  end
  
  def validates_length_of_quote_items
    if quote_items.reject{ |q| q.should_destroy? }.empty?
      errors.add(:quote_item_ids, "Vous devez entrer au moins 1 produit")
    end
  end
  
  def build_quote_item(quote_item_attributes)
    raise ArgumentError, "build_quote_item expected to receive :product_id or :product_reference_id in parameter" if quote_item_attributes[:product_id].blank? and quote_item_attributes[:product_reference_id].blank?
    
    product = Product.find_by_id(quote_item_attributes[:product_id])
    product ||= ProductReference.find_by_id(quote_item_attributes[:product_reference_id])
    
    name        = product.name
    description = product.description
    dimensions  = product.dimensions rescue nil # ProductReference do not have dimensions
    quantity    = product.quantity rescue nil   # ProductReference do not have quantity
    unit_price  = product.unit_price
    vat         = product.vat || ( product.product_reference.vat rescue nil )
    
    quote_item_attributes = { :name         => name,
                              :description  => description,
                              :dimensions   => dimensions,
                              :quantity     => quantity,
                              :unit_price   => unit_price,
                              :vat          => vat
                            }.merge(quote_item_attributes)
    
    _build_quote_item(quote_item_attributes)
  end
  
  def quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      _build_quote_item(attributes)
    end
    
    # automatically remove a product from order if quote_items do not include this product
    order.products.reject(&:new_record?).each do |p|
      @order_products_to_remove << p unless quote_items.collect(&:product_id).include?(p.id)
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
  
  def remove_order_products
    @order_products_to_remove.each(&:destroy)
  end
  
  def total
    quote_items.collect(&:total).sum
  end
  
  def net
    reduction = self.reduction || 0.0
    total*(1-(reduction/100))
  end
  
  def total_with_taxes
    quote_items.collect(&:total_with_taxes).sum
  end
  
  def summon_of_taxes
    total_with_taxes - total
  end
  
  def net_to_paid
    carriage_costs = self.carriage_costs || 0.0
    discount = self.discount || 0.0
    net + carriage_costs + summon_of_taxes - discount
  end
  
  def account_with_taxes
    account = self.account || 0.0
    account*(1+(ConfigurationManager.sales_account_tax_coefficient/100))
  end
  
  def tax_coefficients
    quote_items.collect(&:vat).uniq
  end
  
  def total_taxes_for(coefficient)
    quote_items.select{ |i| i.vat == coefficient }.collect(&:total).sum
  end
  
  def number_of_pieces
    quote_items.collect(&:quantity).sum
  end
  
  def confirm
    if can_be_confirmed?
      self.confirmed_on = Date.today
      self.reference = generate_reference
      self.status = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_on = Date.today
      self.status = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
  def send_to_customer(attributes)
    if can_be_sended?
      if attributes[:sended_on] and attributes[:sended_on].kind_of?(Date)
        self.sended_on = attributes[:sended_on]
      else
        self.sended_on = Date.civil( attributes["sended_on(1i)"].to_i,
                                     attributes["sended_on(2i)"].to_i,
                                     attributes["sended_on(3i)"].to_i ) rescue nil # return nil if the date is invalid
      end
      self.send_quote_method_id = attributes[:send_quote_method_id]
      self.status = STATUS_SENDED
      self.save
    else
      false
    end
  end
  
  def sign(attributes)
    if can_be_signed?
      self.attributes = attributes
      if attributes[:signed_on] and attributes[:signed_on].kind_of?(Date)
        self.signed_on = attributes[:signed_on]
      else
        self.signed_on = Date.civil( attributes["signed_on(1i)"].to_i,
                                     attributes["signed_on(2i)"].to_i,
                                     attributes["signed_on(3i)"].to_i ) rescue nil
      end
      self.order_form_type_id = attributes[:order_form_type_id]
      self.order_form = attributes[:order_form]
      self.status = STATUS_SIGNED
      self.save
    else
      false
    end
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
    return unless confirmed_on and validity_delay_unit and validity_delay
    confirmed_on + validity_delay.send(validity_delay_unit)
  end
  
  def can_be_added?
    order.draft_quote.nil? and order.pending_quote.nil? and order.signed_quote.nil?
  end
  
  def can_be_edited? # we don't choose 'can_edit?' to avoid conflict with 'has_permissions' methods
    was_uncomplete?
  end
  
  def can_be_deleted?
    was_uncomplete?
  end
  
  def can_be_confirmed?
    #was_uncomplete? and estimate_step.pending_quote.nil? and estimate_step.signed_quote.nil?
    was_uncomplete? and order.pending_quote.nil? and order.signed_quote.nil?
  end
  
  def can_be_cancelled?
    was_uncomplete? or was_confirmed? or was_sended?
  end
  
  def can_be_sended?
    was_confirmed?
  end
  
  def can_be_signed?
    was_sended?
  end
  
  def order_contacts
    # use EstimateStep.find() permits to get a complete list of contacts (if order contacts
    # list has changed from the initial 'find' of the current instance of Quote)
    
    #estimate_step ? EstimateStep.find(estimate_step_id).order.contacts : []
    order ? order.contacts : []
  end
  
  private

    def update_estimate_step_status
      if signed?
        #estimate_step.terminated!
        order.commercial_step.estimate_step.terminated!
      end
    end
    
    def _build_quote_item(quote_item_attributes)
      return nil if quote_item_attributes[:product_reference_id].blank?
      
      quote_item_attributes[:product_attributes] = quote_item_attributes.reject{ |k,v| [:product_id, :order_id].include?(k.to_sym) }
      quote_item_attributes[:product_attributes][:id] = quote_item_attributes[:product_id]
      quote_item_attributes.delete(:product_reference_id)
      quote_item_attributes[:order_id] = self.order_id
      
      if quote_item_attributes[:id].blank?
        quote_item = quote_items.build(quote_item_attributes)
      else
        quote_item = quote_items.detect { |x| x.id == quote_item_attributes[:id].to_i }
        quote_item.attributes = quote_item_attributes
      end
      
      return quote_item
    end
end
