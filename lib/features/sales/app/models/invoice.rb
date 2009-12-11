class Invoice < ActiveRecord::Base
  STATUS_CONFIRMED            = 'confirmed'
  STATUS_CANCELLED            = 'cancelled'
  STATUS_SENDED               = 'sended'
  STATUS_ABANDONED            = 'abandoned'
  STATUS_FACTORING_PAID       = 'factoring_paid'
  STATUS_FACTORING_RECOVERED  = 'factoring_recovered'
  STATUS_TOTALLY_PAID         = 'totally_paid'
  
  REFERENCE_PATTERN = "%Y%m" # 1 Jan 2009 => 200901
  
  has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :due_date_pay ]
  has_contact :accept_from => :order_contacts
  has_address :bill_to_address
  
  belongs_to :order
  belongs_to :invoice_type
  belongs_to :send_invoice_method
  belongs_to :cancelled_by, :class_name => "Employee"
  belongs_to :abandoned_by, :class_name => "Employee"
  
  has_many :invoice_items, :dependent => :destroy
  has_many :products,       :through => :invoice_items
  has_many :product_items,  :class_name => "InvoiceItem", :conditions => [ "product_id IS NOT NULL"]
  has_many :free_items,     :class_name => "InvoiceItem", :conditions => [ "product_id IS NULL"]
  
  has_many :delivery_notes
  has_many :dunnings,   :dependent => :destroy
  has_many :due_dates,  :dependent => :destroy
  
  has_one :upcoming_due_date, :class_name => 'DueDate', :conditions => [ "paid_at IS NULL" ], :order => "date ASC"
  
  #named_scope :unpaid_by_factor, :include => [:due_dates], :conditions => [ "factorised = ?", true ] # facture factorisée non payées par le factor après le délai factor (48h par exemple)
  
  attr_accessor :the_due_date_to_pay # only one due_date can be paid at time, and it's stored in this accessor
  
  # when invoice is UNSAVED
  with_options :if => :new_record? do |x|
    x.validates_inclusion_of :status, :in => [ nil ]
  end
  
  # when invoice is UNCOMPLETE
  with_options :if => :was_uncomplete? do |x|
    x.validates_inclusion_of :status, :in => [ nil, STATUS_CONFIRMED ]
    x.validates_persistence_of :order_id, :invoice_type_id, :factorised
  end
  
  # when invoice is UNSAVED or UNCOMPLETE
  with_options :if => Proc.new{ |invoice| invoice.new_record? or invoice.was_uncomplete? } do |x|
    x.validates_presence_of :bill_to_address, :invoice_type_id
    x.validates_presence_of :invoice_type, :if => :invoice_type_id
    
    x.validates_length_of :invoice_item_ids, :due_date_ids, :contact_ids, :minimum => 1
  end
  
  # when invoice is UNCOMPLETE and above
  with_options :if => :created_at_was do |x|
    # nothing...
  end

  ### while invoice CONFIRMATION
  with_options :if => Proc.new{ |i| i.created_at_was and i.confirmed? } do |x|
    x.validates_presence_of :confirmed_at, :reference
    
    x.validates_date :confirmed_at, :on_or_after         => :created_at,
                                    :on_or_after_message => "ne doit pas être AVANT la date de création de la facture&#160;(%s)"
  end
  
  # when invoice is CONFIRMED
  with_options :if => :was_confirmed? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_SENDED ]
  end
  
  # when invoice is CONFIRMED and above
  with_options :if => :confirmed_at_was do |x|
    x.validates_persistence_of :confirmed_at, :reference, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :contact
  end
  
  ### while invoice CANCELLATION
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.cancelled? } do |x|
    x.validates_presence_of :cancelled_at, :cancelled_comment, :cancelled_by_id
    x.validates_presence_of :cancelled_by, :if => :cancelled_by_id
    
    x.validates_date :cancelled_at, :on_or_after         => :confirmed_at,
                                    :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
  end
  
  ### while invoice SENDING
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.sended? } do |x|
    x.validates_presence_of :sended_on, :send_invoice_method_id
    x.validates_presence_of :send_invoice_method, :if => :send_invoice_method_id
    
    x.validates_date :sended_on,  :on_or_after         => :confirmed_at,
                                  :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
  end
  
  # when invoice is CANCELLED
  with_options :if => :was_cancelled? do |x|
    x.validates_persistence_of :status, :cancelled_at, :cancelled_comment, :cancelled_by_id
  end
  
  # when invoice is SENDED
  with_options :if => :was_sended? do |x|
    # nothing...
  end
  
  # when invoice is SENDED and factorised
  with_options :if => Proc.new{ |i| i.was_sended? and i.was_factorised? } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_SENDED, STATUS_CANCELLED, STATUS_FACTORING_PAID ]
  end
  
  # when invoice is SENDED and normal
  with_options :if => Proc.new{ |i| i.was_sended? and !i.was_factorised? } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_SENDED, STATUS_CANCELLED, STATUS_ABANDONED, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is SENDED and above
  with_options :if => :sended_on_was do |x|
    x.validates_persistence_of :sended_on, :send_invoice_method_id
  end
  
  ### while invoice CANCELLATION
  with_options :if => Proc.new{ |i| i.sended_on_was and i.cancelled? } do |x|
    x.validates_presence_of :cancelled_at, :cancelled_comment, :cancelled_by_id
    x.validates_presence_of :cancelled_by, :if => :cancelled_by_id
    
    x.validates_date :cancelled_at, :on_or_after         => :sended_on,
                                    :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
  end
  
  ### while invoice ABANDONNING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.abandoned? } do |x|
    x.validates_presence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
    x.validates_presence_of :abandoned_by, :if => :abandoned_by_id
    
    x.validates_date :abandoned_on, :on_or_after         => :sended_on,
                                    :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
  end
  
  ### while invoice FACTORING_PAYING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.factoring_paid? } do |x|
    x.validate :validates_presence_of_factoring_payment
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is ABANDONED
  with_options :if => :was_abandoned? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is ABANDONED and above
  with_options :if => :abandoned_on_was do |x|
    x.validates_persistence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.abandoned_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is FACTORING_PAID
  with_options :if => :was_factoring_paid? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_FACTORING_RECOVERED, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is FACTORING_PAID and above
  with_options :if => :factoring_paid_on_was do |x|
    # nothing...
  end
  
  ### while invoice FACTORING_RECOVERED
  with_options :if => Proc.new{ |i| i.factoring_paid_on_was and i.factoring_recovered? } do |x|
    x.validates_presence_of :factoring_recovered_on
    
    x.validates_date :factoring_recovered_on, :on_or_after         => :factoring_paid_on,
                                              :on_or_after_message => "ne doit pas être AVANT la date de réglement par le factor de la facture&#160;(%s)"
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.factoring_paid_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is FACTORING_RECOVERED
  with_options :if => :was_factoring_recovered? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_ABANDONED, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is FACTORING_RECOVERED and above
  with_options :if => :factoring_recovered_on_was do |x|
    x.validates_persistence_of :factoring_recovered_on
  end
  
  ### while invoice ABANDONNING
  with_options :if => Proc.new{ |i| i.factoring_recovered_on_was and i.abandoned? } do |x|
    x.validates_presence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
    x.validates_presence_of :abandoned_by, :if => :abandoned_by_id
    
    x.validates_date :abandoned_on, :on_or_after         => :factoring_recovered_on,
                                    :on_or_after_message => "ne doit pas être AVANT la date de définancement par le factor de la facture&#160;(%s)"
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.factoring_recovered_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is TOTALLY_PAID
  with_options :if => :was_totally_paid? do |x|
    x.validates_persistence_of :status
  end
  
  validates_associated :invoice_items, :products, :due_dates
  
  validate :validates_uniqueness_of_due_dates_with_factorised_invoice
  validate :validates_due_dates_amount, :if => :new_record?
  
  attr_protected :status, :reference, :cancelled_by, :abandoned_by, :confirmed_at, :cancelled_at
  
  after_save :save_invoice_items, :save_due_dates, :save_due_date_to_pay
  
  before_destroy :check_if_can_be_destroyed
  
  def validates_uniqueness_of_due_dates_with_factorised_invoice
    errors.add(:due_dates, "Une facture factorisée ne peut avoir qu'une seule échéance") if factorised? and due_dates.size > 1
  end
  
  def validates_presence_of_factoring_payment
    errors.add(:factoring_payment, "Le réglement du factor est nécessaire pour continuer") unless factoring_payment
  end
  
  def validates_due_dates_amount
    unless ( total_of_due_dates = due_dates.collect{ |d| d.net_to_paid.to_f }.sum.to_f ) == net_to_paid.to_f
      errors.add(:due_dates, "La somme des montants des échéances ne correspond pas au montant total de la facture (#{total_of_due_dates} <> #{net_to_paid.to_f}")
    end
  end
  
  def validates_due_dates_payments_before_totally_pay
    errors.add(:due_dates, "La somme des réglements des échéances ne correspond pas au montant total de la facture") unless really_totally_paid?
  end
  
  def associated_quote
    order ? order.signed_quote : nil
  end
  
  def total
    invoice_items.collect(&:total).sum
  end
  
  def net
    return 0.0 unless associated_quote
    reduction = associated_quote.reduction || 0.0
    total*(1-(reduction/100))
  end
  
  def total_with_taxes
    invoice_items.collect(&:total_with_taxes).sum
  end
  
  def summon_of_taxes
    total_with_taxes - total
  end
  
  def net_to_paid
    return unless associated_quote
    carriage_costs = associated_quote.carriage_costs || 0.0
    discount = associated_quote.discount || 0.0
    net + carriage_costs + summon_of_taxes - discount
  end
  
  def total_taxes_for(coefficient)
    invoice_items.select{ |i| i.vat == coefficient }.collect(&:total).sum
  end
  
  def number_of_pieces
    invoice_items.collect(&:quantity).sum
  end
  
  def already_paid_amount
    due_dates.collect{ |d| d.total_amounts.to_f }.sum
  end
  
  def balance_to_be_paid
    net_to_paid - already_paid_amount
  end
  
  def really_totally_paid?
    balance_to_be_paid == 0
  end
  
  def build_invoice_item_from(product)
    return if product.nil? or product.new_record?
    invoice_items.build( :product_id  => product.id,
                         :quantity    => product.quantity,
                         :discount    => product.discount,
                         :name        => product.name,
                         :description => product.description )
  end
  
  def build_invoice_items_from_products
    return unless order
    order.products.each do |p|
      build_invoice_item_from(p)
    end
    return invoice_items
  end
  
  def invoice_item_attributes=(invoice_item_attributes)
    invoice_item_attributes.each do |attributes|
      if attributes[:id].blank?
        invoice_item = invoice_items.build(attributes)
      else
        invoice_item = invoice_items.detect { |x| x.id == attributes[:id].to_i }
        invoice_item.attributes = attributes
      end
    end
  end
  
  def save_invoice_items
    return if confirmed_at_was
    invoice_items.each do |i|
      i.save(false)
    end
  end
  
  def due_date_attributes=(due_date_attributes)
    due_date_attributes.each do |attributes|
      if attributes[:id].blank?
        due_date = due_dates.build(attributes)
      else
        due_date = due_dates.detect{ |d| d.id == attributes[:id].to_i }
        due_date.attributes = attributes
      end
    end
  end
  
  def save_due_dates
    return if confirmed_at_was
    due_dates.each do |d|
      if d.should_destroy?
        d.destroy
      else
        d.save(false)
      end
    end
  end
  
  def due_date_to_pay=(attributes)
    self.the_due_date_to_pay = due_dates.detect{ |d| d.id == attributes[:id].to_i }
    
    if self.the_due_date_to_pay and self.the_due_date_to_pay.invoice_id == self.id
      self.the_due_date_to_pay.attributes = attributes
    end
  end
  
  def save_due_date_to_pay
    return unless factoring_paid? or totally_paid?
    the_due_date_to_pay.save(false) if the_due_date_to_pay
  end
  
  def confirm
    if can_be_confirmed?
      self.confirmed_at = Time.now
      self.reference    = generate_reference
      self.status       = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def cancel(cancel_attributes)
    if can_be_cancelled?
      self.cancelled_at       = Time.now
      self.cancelled_by_id    = cancel_attributes[:cancelled_by_id].to_i
      self.cancelled_comment  = cancel_attributes[:cancelled_comment]
      self.status             = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
  def send_to_customer(send_attributes)
    if can_be_sended?
      self.sended_on              = Date.today
      self.send_invoice_method_id = send_attributes[:send_invoice_method_id].to_i
      self.status                 = STATUS_SENDED
      self.save
    else
      false
    end
  end
  
  def abandon(abandon_attributes)
    if can_be_abandoned?
      self.abandoned_on       = Time.now
      self.abandoned_by_id    = abandon_attributes[:abandoned_by_id].to_i
      self.abandoned_comment  = abandon_attributes[:abandoned_comment]
      self.status             = STATUS_ABANDONED
      self.save
    else
      false
    end
  end
  
  def factoring_pay(factoring_pay_attributes)
    if can_be_factoring_paid?
      self.due_date_to_pay  = factoring_pay_attributes[:due_date_to_pay]
      self.status           = STATUS_FACTORING_PAID
      self.save
    else
      false
    end
  end
  
  def factoring_recover
    if can_be_factoring_recovered?
      self.factoring_recovered_on = Date.today
      self.status                 = STATUS_FACTORING_RECOVERED
      self.save
    else
      false
    end
  end
  
  def totally_pay(totally_pay_attributes)
    if can_be_totally_paid?
      self.due_date_to_pay  = totally_pay_attributes[:due_date_to_pay]
      self.status           = STATUS_TOTALLY_PAID if really_totally_paid?
      self.save
    else
      false
    end
  end
  
  def factorised?
    factorised == true
  end
  
  def was_factorised?
    factorised_was == true
  end
  
  def uncomplete?
    status == nil
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
  
  def abandoned?
    status == STATUS_ABANDONED
  end
  
  def factoring_paid?
    status == STATUS_FACTORING_PAID
  end
  
  def factoring_recovered?
    status == STATUS_FACTORING_RECOVERED
  end
  
  def totally_paid?
    status == STATUS_TOTALLY_PAID
  end
  
  def factoring_payment
    return unless factorised?
    due_dates.collect{ |d| d.payments.detect(&:paid_by_factor?) }.first
  end
  
  def factoring_paid_on
    factoring_payment.paid_on if factoring_payment
  end
  
  def factoring_paid_on_was
    ( factoring_payment.nil? || factoring_payment.new_record? ) ? nil : factoring_payment.paid_on
  end
  
  def factoring_paid_amount
    factoring_payment.amount if factoring_payment
  end
  
  def totally_paid_on
    due_dates.last.payments.last.paid_on if totally_paid?
  end
  
  def was_uncomplete?
    status_was == nil
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
  
  def was_abandoned?
    status_was == STATUS_ABANDONED
  end
  
  def was_factoring_paid?
    status_was == STATUS_FACTORING_PAID
  end
  
  def was_factoring_recovered?
    status_was == STATUS_FACTORING_RECOVERED
  end
  
  def was_totally_paid?
    status_was == STATUS_TOTALLY_PAID
  end
  
  def can_be_edited?
    was_uncomplete?
  end
  
  def can_be_destroyed?
    was_uncomplete?
  end
  
  def can_be_confirmed?
    was_uncomplete?
  end
  
  def can_be_cancelled?
    was_confirmed? or was_sended?
  end
  
  def can_be_sended?
    was_confirmed?
  end
  
  def can_be_abandoned?
    ( was_factorised? and was_factoring_recovered? ) or ( !was_factorised? and was_sended? )
  end
  
  def can_be_factoring_paid?
    was_factorised? and was_sended?
  end
  
  def can_be_factoring_recovered?
    was_factoring_paid?
  end
  
  def can_be_totally_paid?
    ( was_factorised? and ( was_factoring_paid? or was_factoring_recovered? ) ) or ( !was_factorised? and was_sended? ) or was_abandoned?
  end
  
  def dunning_level
  end
  
  def unpaid_amount
  end
  
  def order_contacts
    order ? order.contacts : []
  end
  
  private
    def generate_reference
      return reference unless reference.blank?
      prefix = Date.today.strftime(REFERENCE_PATTERN)
      last_invoice = Invoice.last(:conditions => [ "reference LIKE ?", "#{prefix}%" ])
      quantity = last_invoice ? last_invoice.reference.gsub(/^(#{prefix})/, '').to_i + 1 : 1
      "#{prefix}#{quantity.to_s.rjust(3,'0')}"
    end
    
    def check_if_can_be_destroyed
      can_be_destroyed?
    end
end
