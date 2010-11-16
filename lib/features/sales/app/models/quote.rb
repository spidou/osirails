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
  has_contact     :quote_contact, :accept_from => :order_and_customer_contacts, :required => true
  has_reference   :symbols => [:order], :prefix => :sales
  
  belongs_to :creator, :class_name => 'User'
  belongs_to :order
  belongs_to :send_quote_method
  belongs_to :order_form_type
  
  has_many :quote_items, :dependent => :delete_all, :order => 'position' # not :destroy to avoid after_destroy is called in quote_item.rb
  has_many :end_products, :through => :quote_items
  
  has_attached_file :order_form,
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => '/quotes/:quote_id/order_form'
                    
  journalize :attributes   => [:status, :creator_id,  :quote_contact_id, :reference, :carriage_costs, :prizegiving, 
                               :deposit, :discount, :sales_terms, :validity_delay, :validity_delay_unit, :confirmed_on, 
                               :cancelled_on, :sended_on, :send_quote_method_id, :signed_on, :order_form_type_id, ],
             :subresources => [:quote_items, :bill_to_address, :ship_to_address],
             :attachments  =>  :order_form
  
  named_scope :actives, :conditions => [ 'status IS NULL OR status != ?', STATUS_CANCELLED ]
  
  validates_presence_of :order_id, :creator_id
  validates_presence_of :order,   :if => :order_id
  validates_presence_of :creator, :if => :creator_id
  
  validates_numericality_of :prizegiving, :carriage_costs, :discount, :deposit, :validity_delay
  
  validates_inclusion_of :validity_delay_unit, :in => VALIDITY_DELAY_UNITS.values
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED, STATUS_CANCELLED, STATUS_SENDED, STATUS_SIGNED ], :allow_nil => true
  
  validates_associated :quote_items, :end_products
  
  validate :validates_length_of_quote_items
  
  ## VALIDATIONS ON VALIDATING QUOTE
  with_options :if => Proc.new{ |i| i.created_at_was and i.confirmed? } do |quote|
    quote.validates_date :confirmed_on, :on_or_after => :created_at
    quote.validates_presence_of   :reference
  end
  
  ## VALIDATIONS ON INVALIDATING QUOTE
  validates_date :cancelled_on, :on_or_after => :created_at,
                                :if          => Proc.new{ |i| i.created_at_was and i.cancelled? }
  
  ## VALIDATIONS ON SENDING QUOTE
  with_options :if => :sended? do |quote|
    quote.validates_date  :sended_on, :on_or_after  => :confirmed_on,
                                      :on_or_before => Date.today
    
    quote.validates_presence_of :send_quote_method_id
    quote.validates_presence_of :send_quote_method, :if => :send_quote_method_id # prevent errors by providing wrong ID
  end
  
  ## VALIDATIONS ON SIGNING QUOTE
  with_options :if => :signed? do |quote|
    quote.validates_presence_of :order_form_type_id, :order_form
    quote.validates_presence_of :order_form_type, :if => :order_form_type_id
    
    quote.validates_date  :signed_on, :on_or_after  => :sended_on,
                                      :on_or_before => Date.today
    
    quote.validate :validates_presence_of_order_form
  end
  
  after_save    :save_quote_items, :remove_order_end_products
  after_update  :update_quote_step_status
  
  attr_protected :status, :confirmed_on, :cancelled_on
  
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
    if product_quote_items.reject(&:should_destroy?).empty?
      errors.add(:quote_item_ids, "Vous devez entrer au moins 1 produit")
    end
  end
  
  def prizegiving
    self[:prizegiving] ||= 0.0
  end
  
  def carriage_costs
    self[:carriage_costs] ||= 0.0
  end
  
  def discount
    self[:discount] ||= 0.0
  end
  
  def product_quote_items
    quote_items.select(&:end_product)
  end
  
  def free_quote_items
    quote_items.reject(&:end_product)
  end
  
  def sorted_quote_items
    quote_items.sort_by(&:position)
  end
  
  def build_quote_item(quote_item_attributes)
    raise ArgumentError, "build_quote_item expected to receive :end_product_id or :product_reference_id in parameter" if quote_item_attributes[:end_product_id].blank? and quote_item_attributes[:product_reference_id].blank?
    
    product = EndProduct.find_by_id(quote_item_attributes[:end_product_id])
    product ||= ProductReference.find_by_id(quote_item_attributes[:product_reference_id])
    
    name                 = product.name
    description          = product.description
    dimensions           = product.dimensions
    quantity             = product.quantity rescue nil # ProductReference do not have quantity
    unit_price           = product.unit_price
    prizegiving          = product.prizegiving
    vat                  = product.vat || ( product.product_reference.vat rescue nil )
    product_reference_id = quote_item_attributes[:product_reference_id] || product.product_reference.id
    
    quote_item_attributes = { :product_reference_id => product_reference_id,
                              :name                 => name,
                              :description          => description,
                              :dimensions           => dimensions,
                              :unit_price           => unit_price,
                              :prizegiving          => prizegiving,
                              :quantity             => quantity,
                              :vat                  => vat
                            }.merge(quote_item_attributes)
    
    build_or_update_quote_item(quote_item_attributes)
  end
  
  def product_quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      build_or_update_quote_item(attributes)
    end
    
    # automatically remove a end_product from order if quote_items do not include this end_product
    order.end_products.reject(&:new_record?).each do |p|
      @order_end_products_to_remove << p unless product_quote_items.collect(&:end_product_id).include?(p.id)
    end
  end
  
  def free_quote_item_attributes=(quote_item_attributes)
    quote_item_attributes.each do |attributes|
      build_or_update_quote_item(attributes) unless attributes[:name].blank? and attributes[:description].blank? and attributes[:dimensions].blank? and attributes[:unit_price].blank? and attributes[:prizegiving].blank? and attributes[:quantity].blank? and attributes[:vat].blank?
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
  
  def total
    product_quote_items.collect(&:total).sum
  end
  
  def net
    prizegiving = self.prizegiving || 0.0
    total * ( 1 - ( prizegiving / 100 ) )
  end
  
  def total_with_taxes
    product_quote_items.collect(&:total_with_taxes).sum
  end
  
  def summon_of_taxes
    total_with_taxes - total
  end
  
  def net_to_paid
    carriage_costs = self.carriage_costs || 0.0
    discount = self.discount || 0.0
    net + carriage_costs + summon_of_taxes - discount
  end
  
  def tax_coefficients
    product_quote_items.collect(&:vat).uniq
  end
  
  def total_taxes_for(coefficient)
    product_quote_items.select{ |i| i.vat == coefficient }.collect(&:total).sum
  end
  
  def number_of_pieces
    product_quote_items.collect(&:quantity).compact.sum
  end
  
  def number_of_products
    product_quote_items.count
  end
  
  def confirm
    if can_be_confirmed?
      update_reference
      self.confirmed_on = Date.today
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
      self.attributes = attributes
      self.status = STATUS_SENDED
      self.save
    else
      false
    end
  end
  
  def sign(attributes)
    if can_be_signed?
      self.attributes = attributes
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
    order.draft_quote(true).nil? and order.pending_quote(true).nil? and order.signed_quote(true).nil?
  end
  
  def can_be_edited? # we don't choose 'can_edit?' to avoid conflict with 'has_permissions' methods
    !new_record? and was_uncomplete?
  end
  
  def can_be_downloaded? # with PDF generator
    reference_was
  end
  
  def can_be_deleted?
    !new_record? and was_uncomplete?
  end
  
  def can_be_confirmed?
    #was_uncomplete? and quote_step.pending_quote.nil? and quote_step.signed_quote.nil?
    !new_record? and was_uncomplete? and order.pending_quote(true).nil? and order.signed_quote(true).nil?
  end
  
  def can_be_cancelled?
    !new_record? and ( was_uncomplete? or was_confirmed? or was_sended? )
  end
  
  def can_be_sended?
    was_confirmed?
  end
  
  def can_be_signed?
    was_sended? and order.signed_quote(true).nil?
  end
  
  def order_and_customer_contacts
    order ? order.all_contacts_and_customer_contacts : []
  end
  
  private
    def update_quote_step_status
      if signed?
        order.commercial_step.quote_step.terminated!
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
