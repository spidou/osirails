class Quote < ActiveRecord::Base
  STATUS_VALIDATED    = 'validated'
  STATUS_INVALIDATED  = 'invalidated'
  STATUS_SENDED       = 'sended'
  STATUS_SIGNED       = 'signed'
  
  PUBLIC_NUMBER_PATTERN = "%Y%m" # 1 Jan 2009 => 200901
  
  VALIDITY_DELAY_UNITS = { 'heures' => 'hours',
                           'jours'  => 'days',
                           'mois'   => 'months' }
  
  has_permissions :as_business_object
  has_address     :bill_to_address
  has_address     :ship_to_address
  has_contact     :accept_from => :order_contacts
  
  belongs_to :creator,          :class_name  => 'User', :foreign_key => 'user_id'
  belongs_to :estimate_step
  belongs_to :send_quote_method
  belongs_to :order_form_type
  
  has_many :quotes_product_references, :dependent => :destroy
  has_many :product_references,        :through   => :quotes_product_references
  
  has_attached_file :order_form,
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url => '/quotes/:quote_id/order_form'
  
  validates_contact_presence
  
  validates_presence_of     :estimate_step_id, :user_id, :quotes_product_references
  validates_presence_of     :estimate_step, :if => :estimate_step
  validates_presence_of     :creator,       :if => :user_id
  
  validates_numericality_of :reduction, :carriage_costs, :account, :validity_delay
  
  validates_inclusion_of    :validity_delay_unit, :in => VALIDITY_DELAY_UNITS.values
  validates_inclusion_of    :status, :in => [ STATUS_VALIDATED, STATUS_INVALIDATED, STATUS_SENDED, STATUS_SIGNED ], :allow_nil => true
  
  validates_associated      :quotes_product_references, :product_references
  
  ## VALIDATIONS ON VALIDATING QUOTE
  validates_date :validated_on, :equal_to => Proc.new { Date.today }, :if => :validated?
  
  ## VALIDATIONS ON INVALIDATING QUOTE
  validates_date :invalidated_on, :equal_to => Proc.new { Date.today }, :if => :invalidated?
  
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
  
  def validates_presence_of_order_form # the method validates_attachment_presence of paperclip seems to be broken when using conditions
    if order_form.nil? or order_form.instance.order_form_file_name.blank? or order_form.instance.order_form_file_size.blank? or order_form.instance.order_form_content_type.blank?
      errors.add(:order_form, "est requis")
    end
  end
  
  after_update :save_quotes_product_references, :update_estimate_step_status
  
  attr_protected :status, :public_number, :validated_on, :invalidated_on, :sended_on, :send_quote_method_id,
                 :signed_on, :order_form_type_id, :order_form
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:validity_delay]    = 'Période de validité :'
  @@form_labels[:sended_on]         = 'Devis envoyé au client le :'
  @@form_labels[:send_quote_method] = 'Par :'
  @@form_labels[:signed_on]         = 'Devis signé par client le :'
  @@form_labels[:order_form_type]   = 'Type de document :'
  @@form_labels[:order_form]        = 'Fichier :'
  
  def quotes_product_reference_attributes=(quotes_product_reference_attributes)
    quotes_product_reference_attributes.each do |attributes|
      unless attributes[:product_reference_id].blank?
        if attributes[:id].blank?
          product_reference = ProductReference.find(attributes[:product_reference_id])
          
          quotes_product_reference = quotes_product_references.build(attributes)
          
          # original_name, original_description and original_unit_price are protected form mass-assignment !
          quotes_product_reference.original_name        = product_reference.name
          quotes_product_reference.original_description = product_reference.description
          quotes_product_reference.original_unit_price  = product_reference.unit_price
        else
          quotes_product_reference = quotes_product_references.detect { |x| x.id == attributes[:id].to_i }
          quotes_product_reference.attributes = attributes
        end
      end
    end
  end
  
  def save_quotes_product_references
    quotes_product_references.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end
  
  def update_estimate_step_status
    if signed?
      estimate_step.terminated!
    end
  end
  
  def total
    quotes_product_references.collect{ |qpr| qpr.total }.sum
  end
  
  def net
    total - reduction + carriage_costs
  end
  
  def total_with_taxes
    quotes_product_references.collect{ |qpr| qpr.total_with_taxes }.sum
  end
  
  def summon_of_taxes
    total_with_taxes - total
  end
  
  def net_to_paid
    total_with_taxes - account
  end
  
  def number_of_pieces
    quotes_product_references.collect{ |qpr| qpr.quantity }.sum
  end
  
  def validate_quote
    if can_be_validated?
      self.validated_on = Date.today
      self.public_number = generate_public_number
      self.status = STATUS_VALIDATED
      self.save
    else
      false
    end
  end
  
  def invalidate_quote
    if can_be_invalidated?
      self.invalidated_on = Date.today
      self.status = STATUS_INVALIDATED
      self.save
    else
      false
    end
  end
  
  def send_quote(attributes)
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
  
  def sign_quote(attributes)
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
  
  def validated?
    status == STATUS_VALIDATED
  end
  
  def invalidated?
    status == STATUS_INVALIDATED
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
  
  def was_validated?
    status_was == STATUS_VALIDATED
  end
  
  def was_invalidated?
    status_was == STATUS_INVALIDATED
  end
  
  def was_sended?
    status_was == STATUS_SENDED
  end
  
  def was_signed?
    status_was == STATUS_SIGNED
  end
  
  def validity_date
    return unless validated_on and validity_delay_unit and validity_delay
    validated_on + validity_delay.send(validity_delay_unit)
  end
  
  def can_be_edited? # we don't choose 'can_edit?' to avoid conflict with 'has_permissions' methods
    was_uncomplete?
  end
  
  def can_be_deleted?
    was_uncomplete?
  end
  
  def can_be_validated?
    was_uncomplete? and estimate_step.pending_quote.nil? and estimate_step.signed_quote.nil?
  end
  
  def can_be_invalidated?
    was_validated? or was_sended?
  end
  
  def can_be_sended?
    was_validated?
  end
  
  def can_be_signed?
    was_sended?
  end
  
  def order_contacts
    # use EstimateStep.find() permits to get a complete list of contacts (if order contacts
    # list has changed from the initial 'find' of the current instance of Quote)
    estimate_step ? EstimateStep.find(estimate_step_id).order.contacts : []
  end
  
  private
    def generate_public_number
      return public_number if !public_number.blank?
      prefix = Date.today.strftime(PUBLIC_NUMBER_PATTERN)
      quantity = Quote.find(:all, :conditions => [ "public_number LIKE ?", "#{prefix}%" ]).size + 1
      "#{prefix}#{quantity.to_s.rjust(3,'0')}"
    end
end
