## DATABASE STRUCTURE
# A integer  "order_id"
# A integer  "factor_id"
# A integer  "invoice_type_id"
# A integer  "send_invoice_method_id"
# A integer  "invoicing_actor_id"
# A integer  "invoice_contact_id"
# A string   "reference"
# A string   "status"
# A text     "cancelled_comment"
# A text     "abandoned_comment"
# A text     "factoring_recovered_comment"
# A date     "published_on"
# A date     "sended_on"
# A date     "abandoned_on"
# A date     "factoring_recovered_on"
# A date     "factoring_balance_paid_on"
# A datetime "confirmed_at"
# A datetime "cancelled_at"
# A float    "deposit"
# A float    "deposit_vat"
# A decimal  "deposit_amount",              :precision => 65, :scale => 20
# A text     "deposit_comment"
# A datetime "created_at"
# A datetime "updated_at"
    
class Invoice < ActiveRecord::Base
  # status
  STATUS_CONFIRMED              = 'confirmed'
  STATUS_CANCELLED              = 'cancelled'
  STATUS_SENDED                 = 'sended' # rename 'sended' to 'sent'
  STATUS_ABANDONED              = 'abandoned'
  STATUS_DUE_DATE_PAID          = 'due_date_paid'
  STATUS_TOTALLY_PAID           = 'totally_paid'
  STATUS_FACTORING_PAID         = 'factoring_paid'
  STATUS_FACTORING_RECOVERED    = 'factoring_recovered'
  STATUS_FACTORING_BALANCE_PAID = 'factoring_balance_paid'
  
  # invoice types
  DEPOSITE_INVOICE  = 'deposit_invoice'
  STATUS_INVOICE    = 'status_invoice'
  BALANCE_INVOICE   = 'balance_invoice'
  ASSET_INVOICE     = 'asset_invoice'
  
  # range for due_dates number for 1 invoice
  MIN_DUE_DATES = 1
  MAX_DUE_DATES = 5
  
  # priorities based on due_dates, payments and dunnings
  VERY_LOW_PRIORITY = 'very_low_priority'
  LOW_PRIORITY      = 'low_priority'
  MEDIUM_PRIORITY   = 'medium_priority'
  HIGH_PRIORITY     = 'high_priority'
  
  has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :factoring_recover, :factoring_balance_pay, :due_date_pay, :totally_pay ]
  has_contact     :invoice_contact, :accept_from => :order_and_customer_contacts
  has_address     :bill_to_address
  has_reference   :symbols => [:order], :prefix => :sales
  
  belongs_to :order
  belongs_to :factor
  belongs_to :invoice_type
  belongs_to :send_invoice_method
  belongs_to :invoicing_actor, :class_name => 'Employee'
  
  has_many :invoice_items, :dependent  => :destroy, :order => 'position, id'
  
  has_many :delivery_note_invoices, :dependent  => :destroy
  has_many :delivery_notes,         :through    => :delivery_note_invoices
  
  has_many :due_dates, :order => "date ASC",  :dependent => :destroy
  
  has_many :dunnings, :as => :has_dunning, :order => "created_at DESC"
  
  named_scope :actives, :conditions => [ 'status IS NULL OR status != ?', STATUS_CANCELLED ], :order => "invoices.created_at DESC"
  
  named_scope :pending, :conditions => [ 'status IS NULL OR status IN (?)', [STATUS_CONFIRMED, STATUS_SENDED, STATUS_DUE_DATE_PAID, STATUS_FACTORING_PAID, STATUS_FACTORING_RECOVERED] ], :order => "invoices.created_at DESC"
  named_scope :billed,  :conditions => [ 'status IS NOT NULL AND status != ?', STATUS_CANCELLED ]
  named_scope :unpaid,  :conditions => [ 'status IN (?)', [STATUS_CONFIRMED, STATUS_SENDED, STATUS_DUE_DATE_PAID, STATUS_FACTORING_PAID, STATUS_FACTORING_RECOVERED] ], :order => "invoices.created_at DESC" # we don't consider draft invoices as unpaid invoices. to get drafts, use 'pending'.
  named_scope :paid,    :conditions => [ 'status IN (?)', [STATUS_TOTALLY_PAID, STATUS_FACTORING_BALANCE_PAID] ], :order => "invoices.created_at DESC"
  
  attr_accessor :the_due_date_to_pay # only one due_date can be paid at time, and it's stored in this accessor
  
  validates_associated :invoice_items, :delivery_note_invoices, :delivery_notes, :dunnings, :due_dates
  
  # when invoice is UNSAVED
  with_options :if => :new_record? do |x|
    x.validates_inclusion_of :status, :in => [ nil ]
  end
  
  # when invoice is UNCOMPLETE
  with_options :if => :was_uncomplete? do |x|
    x.validates_inclusion_of :status, :in => [ nil, STATUS_CONFIRMED ]
    x.validates_persistence_of :order_id, :invoice_type_id
  end
  
  # when invoice is UNSAVED or UNCOMPLETE
  with_options :if => Proc.new{ |invoice| invoice.new_record? or invoice.was_uncomplete? } do |x|
    x.validates_presence_of :bill_to_address, :invoice_type_id, :invoicing_actor_id, :invoice_contact_id
    x.validates_presence_of :invoice_type,    :if => :invoice_type_id
    x.validates_presence_of :invoicing_actor, :if => :invoicing_actor_id
    x.validates_presence_of :invoice_contact, :if => :invoice_contact_id
    
    x.validate :validates_presence_of_at_least_one_due_date
    x.validate :validates_presence_of_deposit_attributes
    x.validate :validates_invoice_type
  end
  
  # when invoice is UNCOMPLETE and above
  with_options :if => :created_at_was do |x|
    # nothing...
  end

  ### while invoice CONFIRMATION
  with_options :if => Proc.new{ |i| i.created_at_was and i.confirmed? } do |x|
    x.validates_presence_of :confirmed_at, :published_on, :reference
    
    x.validates_date :confirmed_at, :on_or_after => :created_at
    x.validates_date :published_on, :on_or_after => Proc.new{ |i| i.signed_quote.signed_on }
  end
  
  # when invoice is CONFIRMED
  with_options :if => :was_confirmed? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_SENDED ]
  end
  
  # when invoice is CONFIRMED and above
  with_options :if => :confirmed_at_was do |x|
    x.validates_persistence_of :confirmed_at, :published_on, :factor_id, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :invoicing_actor_id, :invoice_contact_id
  end
  
  ### while invoice CANCELLATION (when was confirmed)
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.cancelled? } do |x|
    x.validates_presence_of :cancelled_at, :cancelled_comment
    x.validates_date :cancelled_at, :on_or_after         => :confirmed_at,
                                    :on_or_after_message => :message_for_validates_date_cancelled_at_on_or_after_while_confirmed
  end
  
  # when invoice is CANCELLED
  with_options :if => :was_cancelled? do |x|
    x.validates_persistence_of :status, :cancelled_at, :cancelled_comment
  end
  
  ### while invoice SENDING
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.sended? } do |x|
    x.validates_presence_of :sended_on, :send_invoice_method_id
    x.validates_presence_of :send_invoice_method, :if => :send_invoice_method_id
    
    x.validates_date :sended_on,  :on_or_after  => :published_on
    x.validates_date :sended_on,  :on_or_before => Date.today
  end
  
  # when invoice is SENDED
  with_options :if => :was_sended? do |x|
    # nothing...
  end
  
  # when invoice is SENDED and FACTORISED
  with_options :if => Proc.new{ |i| i.was_sended? and i.was_factorised? } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_FACTORING_PAID ]
  end
  
  # when invoice is SENDED and NORMAL (with 1 unpaid due_date)
  with_options :if => Proc.new{ |i| i.was_sended? and !i.was_factorised? and i.unpaid_due_dates.count == 1 } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_ABANDONED, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is SENDED and NORMAL (with more than 1 unpaid due_date)
  with_options :if => Proc.new{ |i| i.was_sended? and !i.was_factorised? and i.unpaid_due_dates.count > 1 } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_ABANDONED, STATUS_DUE_DATE_PAID ]
  end
  
  # when invoice is SENDED and above
  with_options :if => :sended_on_was do |x|
    x.validates_persistence_of :sended_on, :send_invoice_method_id
  end
  
  ### while invoice CANCELLATION (when was sent)
  with_options :if => Proc.new{ |i| i.sended_on_was and i.cancelled? } do |x|
    x.validates_presence_of :cancelled_at, :cancelled_comment
    
    x.validates_date :cancelled_at, :on_or_after         => :sended_on,
                                    :on_or_after_message => :message_for_validates_date_cancelled_at_on_or_after_while_sended
  end
  
  ### while invoice ABANDONNING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.abandoned? } do |x|
    x.validates_presence_of :abandoned_on, :abandoned_comment
    
    x.validates_date :abandoned_on, :on_or_after         => :sended_on,
                                    :on_or_after_message => :message_for_validates_date_abandoned_on_on_or_after_while_sended
  end
  
  ### while invoice FACTORING_PAYING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.factoring_paid? } do |x|
    x.validate :validates_presence_of_factoring_payment
  end
  
  ### while invoice DUE_DATE_PAYING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.due_date_paid? } do |x|
    x.validate :validates_upcoming_due_date_payments_before_due_date_pay
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.sended_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is ABANDONED and NORMAL
  with_options :if => Proc.new{ |i| i.was_abandoned? and !i.factorised? } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_DUE_DATE_PAID, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is ABANDONED and FACTORISED
  with_options :if => Proc.new{ |i| i.was_abandoned? and i.factorised? } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_FACTORING_BALANCE_PAID ]
  end
  
  # when invoice is ABANDONED and above
  with_options :if => :abandoned_on_was do |x|
    x.validates_persistence_of :abandoned_on, :abandoned_comment
  end
  
  ### while invoice DUE_DATE_PAYING
  with_options :if => Proc.new{ |i| i.abandoned_on_was and i.due_date_paid? } do |x|
    x.validate :validates_upcoming_due_date_payments_before_due_date_pay
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => Proc.new{ |i| i.abandoned_on_was and i.totally_paid? } do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  ### while invoice FACTORING_BALANCE_PAYING
  with_options :if => Proc.new{ |i| i.abandoned_on_was and i.factoring_balance_paid? } do |x|
    x.validates_presence_of :factoring_balance_paid_on
    
    x.validates_date :factoring_balance_paid_on, :on_or_after         => :factoring_recovered_on,
                                                 :on_or_after_message => :message_for_validates_date_factoring_balance_paid_on_on_or_after_while_abandoned
  end
  
  # when invoice is FACTORING_PAID
  with_options :if => :was_factoring_paid? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_FACTORING_RECOVERED, STATUS_FACTORING_BALANCE_PAID ]
  end
  
  # when invoice is FACTORING_PAID and above
  with_options :if => :factoring_paid_on_was do |x|
    # nothing...
  end
  
  ### while invoice FACTORING_RECOVERED
  with_options :if => Proc.new{ |i| i.factoring_paid_on_was and i.factoring_recovered? } do |x|
    x.validates_presence_of :factoring_recovered_on, :factoring_recovered_comment
    
    x.validates_date :factoring_recovered_on, :on_or_after => :factoring_paid_on
  end
  
  ### while invoice FACTORING_BALANCE_PAYING
  with_options :if => Proc.new{ |i| i.factoring_paid_on_was and i.factoring_balance_paid? } do |x|
    x.validates_presence_of :factoring_balance_paid_on
    
    x.validates_date :factoring_balance_paid_on, :on_or_after         => :factoring_paid_on,
                                                 :on_or_after_message => :message_for_validates_date_factoring_balance_paid_on_on_or_after_while_factoring_paid
  end
  
  # when invoice is FACTORING_RECOVERED
  with_options :if => :was_factoring_recovered? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_ABANDONED, STATUS_FACTORING_BALANCE_PAID ]
  end
  
  # when invoice is FACTORING_RECOVERED and above
  with_options :if => :factoring_recovered_on_was do |x|
    x.validates_persistence_of :factoring_recovered_on,  :factoring_recovered_comment
  end
  
  ### while invoice ABANDONNING
  with_options :if => Proc.new{ |i| i.factoring_recovered_on_was and i.abandoned? } do |x|
    x.validates_presence_of :abandoned_on, :abandoned_comment
    
    x.validates_date :abandoned_on, :on_or_after         => :factoring_recovered_on,
                                    :on_or_after_message => :message_for_validates_date_abandoned_on_on_or_after_while_factoring_recovered
  end
  
  ### while invoice FACTORING_BALANCE_PAYING
  with_options :if => Proc.new{ |i| i.factoring_recovered_on_was and i.factoring_balance_paid? } do |x|
    x.validates_presence_of :factoring_balance_paid_on
    
    x.validates_date :factoring_balance_paid_on, :on_or_after         => :factoring_recovered_on,
                                                 :on_or_after_message => :message_for_validates_date_factoring_balance_paid_on_on_or_after_on_while_factoring_recovered
  end
  
  # when invoice is FACTORING_BALANCE_PAID
  with_options :if => :was_factoring_balance_paid? do |x|
    x.validates_persistence_of :status
  end
  
  # when invoice is DUE_DATE_PAID (with 1 unpaid due_date)
  with_options :if => Proc.new{ |i| i.was_due_date_paid? and i.unpaid_due_dates.count == 1 } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_ABANDONED, STATUS_TOTALLY_PAID ]
  end
  
  # when invoice is DUE_DATE_PAID (with more than 1 unpaid due_date)
  with_options :if => Proc.new{ |i| i.was_due_date_paid? and i.unpaid_due_dates.count > 1 } do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_ABANDONED, STATUS_DUE_DATE_PAID ]
  end
  
  # when invoice is DUE_DATE_PAID and above
  with_options :if => :factoring_recovered_on_was do |x|
    # nothing...
  end
  
  ### while invoice DUE_DATE_PAYING
  with_options :if => :due_date_paid? do |x|
    x.validate :validates_upcoming_due_date_payments_before_due_date_pay
  end
  
  ### while invoice TOTALLY_PAYING
  with_options :if => :totally_paid? do |x|
    x.validate :validates_due_dates_payments_before_totally_pay
  end
  
  # when invoice is TOTALLY_PAID
  with_options :if => :was_totally_paid? do |x|
    x.validates_persistence_of :status
  end
  
  validate :validates_presence_of_signed_quote
  
  validate :validates_factorised_according_to_invoice_type
  validate :validates_product_invoice_items_according_to_invoice_type
  validate :validates_free_invoice_items_according_to_invoice_type
  validate :validates_invoice_items_according_to_invoice_type
  validate :validates_delivery_note_invoices_according_to_invoice_type
  validate :validates_unique_usage_of_delivery_note
  
  validate :validates_uniqueness_of_due_dates_with_factorised_invoice
  validate :validates_due_date_amounts
  validate :validates_due_date_dates
  validate :validates_payment_dates
  validate :validates_payment_payment_methods
  validate :validates_due_date_payment_amounts_equal_to_net_to_paid
  
  validate :validates_no_new_payments_unless_when_factoring_pay_or_totally_pay
  
  validate :validates_integrity_of_product_invoice_items
  
  journalize :attributes   => [:reference, :status, :published_on, :sended_on, :abandoned_on, :factoring_recovered_on,
                               :factoring_balance_paid_on, :confirmed_at, :cancelled_at,
                               :cancelled_comment, :abandoned_comment, :factoring_recovered_comment,
                               :factor_id, :invoice_type_id, :send_invoice_method_id, :invoicing_actor_id, :invoice_contact_id,
                               :deposit, :deposit_vat, :deposit_amount, :deposit_comment], #only for deposit invoice
             :subresources => [:bill_to_address, :invoice_items, :due_dates]#, :dunnings]
  
  attr_protected :status, :reference, :confirmed_at, :cancelled_at
  
  before_validation :build_or_update_free_invoice_item_for_deposit_invoice
  
  after_save :save_invoice_items
  after_save :save_due_dates
  after_save :save_due_date_to_pay
  after_save :save_delivery_note_invoices
  
  before_destroy :can_be_deleted?
  
  has_search_index :only_attributes    => [ :reference, :status, :published_on, :sended_on, :abandoned_on, :factoring_recovered_on, :factoring_balance_paid_on ],
                   :only_relationships => [ :factor, :invoice_type ]#,:order] #TODO add :order to relationships list when bug #60 will be resolved.
  
  def validates_presence_of_signed_quote
    errors.add(:signed_quote, "La facture doit être associée à un devis signé, mais celui-ci n'est pas présent.") unless signed_quote
  end
  
  def validates_presence_of_factoring_payment
    errors.add(:factoring_payment, "Le réglement du factor est nécessaire pour continuer") unless factoring_payment
  end
  
  def validates_factorised_according_to_invoice_type
    errors.add(:factor_id, "Cette facture ne peut pas être factorisée car cela est incompatible avec le type de facture choisi ou parce que le client n'est pas factorisé") if factorised? and !can_be_factorised?
  end
  
  def validates_product_invoice_items_according_to_invoice_type
    if deposit_invoice?
      errors.add(:product_invoice_items, "Les lignes de produits/prestations de sont pas autorisées pour une facture d'acompte") if product_invoice_items.reject(&:should_destroy?).any? or service_invoice_items.reject(&:should_destroy?).any?
    elsif status_invoice? or balance_invoice?
      invoice_type_text = status_invoice? ? 'situation' : 'solde'
      errors.add(:product_invoice_items, "Les lignes de produits/prestations sont obligatoires pour une facture de #{invoice_type_text}") if product_invoice_items.reject(&:should_destroy?).empty? and service_invoice_items.reject(&:should_destroy?).empty?
    end
  end
  
  def validates_free_invoice_items_according_to_invoice_type
    if deposit_invoice?
      errors.add(:free_invoice_items, "Une facture d'acompte doit contenir au moins une ligne (libre)") if free_invoice_items.reject(&:should_destroy?).empty?
    end
  end
  
  def validates_invoice_items_according_to_invoice_type
    if asset_invoice?
      errors.add(:invoice_items, "Une facture d'avoir doit contenir au moins une ligne (libre)") if invoice_items.reject(&:should_destroy?).empty?
    end
  end
  
  def validates_delivery_note_invoices_according_to_invoice_type
    if deposit_invoice? or asset_invoice?
      invoice_type_text = deposit_invoice? ? 'acompte' : 'avoir'
      errors.add(:delivery_note_invoices, "Une facture d'#{invoice_type_text} ne peut pas être associée à un Bon de Livraison") unless delivery_note_invoices.reject(&:should_destroy?).empty?
    elsif status_invoice?
      errors.add(:invoice_items, "Une facture de sitation ne doit pas contenir l'ensemble des éléments (produits, prestations) restants à facturer. Vous devez soit créer une 'facture de solde', soit retirer certains éléments de la liste") if order.all_is_delivered? and associated_to_all_delivery_notes_without_confirmed_invoice? and associated_to_all_services_without_confirmed_invoice?
    elsif balance_invoice?
      errors.add(:invoice_items, "Une facture de solde doit absolument contenir l'ensemble des éléments (produits, prestations) restant à facturer") unless associated_to_all_delivery_notes_without_confirmed_invoice? and associated_to_all_services_without_confirmed_invoice?
    end
  end
  
  #TODO test this validation method
  def validates_unique_usage_of_delivery_note
    delivery_note_invoices.reject(&:should_destroy?).each do |delivery_note_invoice|
      if invoice = delivery_note_invoice.delivery_note.invoice(true) and invoice != self
        delivery_note_invoice.errors.add(:base, "Ce Bon de Livraison a déjà été utilisé dans une autre facture (#{invoice.reference_or_id}). Merci de le retirer de cette facture, ou d'annuler l'autre facture.")
      end
    end
    errors.add(:delivery_note_invoices, "Un ou plusieurs Bon de Livraison associés ont déjà été utilisé dans une autre facture. Merci de les retirer, ou d'annuler l'autre facture avant d'enregistrer celle-là.") if delivery_note_invoices.reject{ |d| d.errors.empty? }.any?
  end
  
  def validates_presence_of_deposit_attributes
    return true unless deposit_invoice?
    errors.add(:deposit, I18n.t('activerecord.errors.messages.not_a_number')) unless deposit and deposit > 0
    errors.add(:deposit_amount, I18n.t('activerecord.errors.messages.not_a_number')) unless deposit_amount and deposit_amount > 0
    errors.add(:deposit_vat, I18n.t('activerecord.errors.messages.not_a_number')) unless deposit_vat and deposit_vat > 0
  end
  
  def validates_invoice_type
    return unless self.new_record?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture d'acompte pour cette commande") if deposit_invoice? and !can_create_deposit_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture de situation pour cette commande") if status_invoice? and !can_create_status_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture de solde pour cette commande") if balance_invoice? and !can_create_balance_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture d'avoir pour cette commande") if asset_invoice? and !can_create_asset_invoice?
  end
  
  def validates_presence_of_at_least_one_due_date
    errors.add(:due_dates, "Une facture doit avoir au moins une échéance") if due_dates.reject(&:should_destroy?).empty?
  end
  
  def validates_due_dates_payments_before_totally_pay
    errors.add(:due_dates, "La somme des règlements des échéances ne correspond pas au montant total de la facture (#{net_to_paid.round_to(2)} - #{already_paid_amount.round_to(2)} = #{net_to_paid.round_to(2) - already_paid_amount.round_to(2)})") unless really_totally_paid?
  end
  
  def validates_uniqueness_of_due_dates_with_factorised_invoice
    errors.add(:due_dates, "Une facture factorisée ne peut avoir qu'une seule échéance") if factorised? and due_dates.reject(&:should_destroy?).many? #TODO reject(&:should_destroy?) have just been added => write or modify tests for that method to take it in account
  end
  
  #TODO write tests
  def validates_due_date_amounts
    errors.add(:due_dates, "La somme des montants des échéances ne correspond pas au montant total de la facture (#{total_of_due_dates} ≠ #{net_to_paid})") unless total_of_due_dates_equal_to_net_to_paid?
  end
  
  #TODO write tests
  def validates_upcoming_due_date_payments_before_due_date_pay
    return unless due_date = upcoming_due_date
    due_date.errors.add(:payments, "Vous devez ajouter au moins un règlement à la prochaine échéance pour continuer") if due_date.payments.empty?
  end
  
  #TODO write tests
  def validates_due_date_payment_amounts_equal_to_net_to_paid
    return if factorised?
    
    for due_date in due_dates.reject(&:should_destroy?)
      next if due_date.payments.empty?
      
      error_adjustement_text = due_date.adjustments.empty? ? "" : " et des ajustements"
      error_adjustement_calculation = due_date.adjustments.empty? ? "" : " + " + due_date.adjustments.collect{|a|a.amount||0}.join(' + ')
      
      due_date.errors.add(:payments, "La somme des règlements#{error_adjustement_text} ne correspond pas au montant de l'échéance (#{due_date.payments.collect{|p|p.amount||0}.join(' + ')}#{error_adjustement_calculation} = #{due_date.total_amounts.to_f.round_to(2)} ≠ #{due_date.net_to_paid.to_f.round_to(2)})") unless due_date.paid?
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  #TODO write tests
  def validates_due_date_dates
    return unless published_on
    
    for due_date in due_dates.reject(&:should_destroy?)
      due_date.errors.add(:date, "ne doit pas être AVANT la date d'émission de la facture (#{l(self.published_on, :format => :long)})") if due_date.date and due_date.date < published_on
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  #TODO write tests
  def validates_payment_dates
    return unless published_on_was
    
    for due_date in due_dates
      for payment in due_date.payments
        if payment.paid_on
          payment.errors.add(:paid_on, "ne doit pas être AVANT la date d'émission de la facture&#160;(#{l(self.published_on, :format => :long)})") if payment.paid_on < published_on
          payment.errors.add(:paid_on, "ne doit pas être APRÈS aujourd'hui&#160;(#{l(Date.today, :format => :long)})") if payment.paid_on.future?
        end
      end
      
      due_date.errors.add(:payments) unless due_date.payments.reject{ |p| p.errors.empty? }.empty?
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  #TODO Write tests
  def validates_payment_payment_methods
    return unless !factorised? and published_on_was
    
    for due_date in due_dates
      for payment in due_date.payments
        unless payment.payment_method_id
          payment.errors.add(:payment_method_id, I18n.t('activerecord.errors.messages.blank'))
        else
          payment.errors.add(:payment_method, I18n.t('activerecord.errors.messages.blank')) unless payment.payment_method
        end
      end
      
      due_date.errors.add(:payments) unless due_date.payments.reject{ |p| p.errors.empty? }.empty?
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  #TODO write tests
  def validates_no_new_payments_unless_when_factoring_pay_or_totally_pay
    return if factoring_paid? or due_date_paid? or totally_paid?
    
    for due_date in due_dates
      due_date.errors.add(:payments, "L'ajout de nouveaux règlements n'est pas autorisé dans l'état dans lequel se trouve la facture actuellement (#{status})") unless due_date.payments.select(&:new_record?).empty?
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  def validates_integrity_of_product_invoice_items
    return unless status_invoice? or balance_invoice?
    
    delivery_note_items_sum = {}
    delivery_note_invoices.reject(&:should_destroy).collect(&:delivery_note).collect(&:delivery_note_items).flatten.each do |item|
      p_id = item.end_product_id
      if item.really_delivered_quantity > 0
        delivery_note_items_sum[p_id] = ( delivery_note_items_sum[p_id] || 0 ) + item.really_delivered_quantity
      end
    end
    
    product_items_sum = {}
    product_invoice_items.each{ |i| product_items_sum[i.invoiceable_id] = i.quantity if i.quantity > 0 }
    
    if product_items_sum != delivery_note_items_sum
      contents = ""
      product_items_sum.diff(delivery_note_items_sum).keys.each do |key|
        end_product                  = EndProduct.find(key)
        product_item_quantity        = product_items_sum[key]       || 0
        delivery_note_items_quantity = delivery_note_items_sum[key] || 0
        #TODO replace this view logic by a new tag system
        contents                    += "<br/>- #{end_product.name} (quantité à '#{product_item_quantity}' au lieu de '#{delivery_note_items_quantity}')"
      end
      message = contents
      errors.add(:invoice_items, "La liste des produits qui composent la facture est incorrecte. Elle ne correspond pas aux produits livrés dans le(s) 'Bon de Livraison' associé(s) : #{message}") 
    end
  end
  
  #TODO test this method
  #def already_billed_amount
  #  return unless order
  #  @already_billed_amount = order.billed_amount                                # #billed_amount pick all billed invoices, when status is not nil and not cancelled (show the named_scope Invoice#billed)
  #  @already_billed_amount += net_to_paid if was_uncomplete? or was_cancelled?  # so we add the net_to_paid amount of this invoice if it's uncomplete or cancelled
  #  @already_billed_amount
  #end
  
  #TODO test this method
  def already_billed_amount # same as Order#billed_amount, but without the current invoice 
    return 0.0 unless order
    order.invoices.billed.reject{ |i| i == self }.collect(&:net_to_paid).sum
  end
  
  #TODO test this method
  def total_billed_amount # billed amount with the current invoice (unless it's cancelled)
    return 0.0 unless order
    return already_billed_amount if was_cancelled?
    already_billed_amount + net_to_paid
  end
  
  #TODO test this method
  def balance_to_bill_amount #TODO review this method like I did with already_billed_amount and total_billed_amount
    return unless order
    @balance_to_bill_amount = order.unbilled_amount
    @balance_to_bill_amount -= net_to_paid if was_uncomplete? or was_cancelled? # remove value from current invoice if it's uncomplete or cancelled
    @balance_to_bill_amount
  end
  
  def unpaid_due_dates
    due_dates.reject(&:was_paid?)
  end
  
  def upcoming_due_date
    unpaid_due_dates.first
  end
  
  #TODO reject(&:should_destroy?) have just been added => write or modify tests for that method and for the validation method 'validates_due_date_amounts' to take it in account
  def total_of_due_dates
    due_dates.reject(&:should_destroy?).collect{ |d| d.net_to_paid }.sum
  end
  
  def total_of_due_dates_equal_to_net_to_paid? #TODO test if 'to_f' don't fail the calculation
    total_of_due_dates.to_f.round_to(2) == net_to_paid.to_f.round_to(2) # without 'round_to', the 2 values can be different with very very small variation (eg: 7.27595761418343e-12)
  end
  
  def product_invoice_items
    invoice_items.select(&:product_item?)
  end
  
  def service_invoice_items
    invoice_items.select(&:service_item?)
  end
  
  def free_invoice_items
    invoice_items.select(&:free_item?)
  end
  
  def other_invoice_items
    invoice_items.reject(&:product_item?) # contrary of #product_invoice_items
  end
  
  def sorted_invoice_items
    invoice_items.sort_by(&:position)
  end
  
  def sorted_product_invoice_items
    product_invoice_items.sort_by(&:position)
  end
  
  def sorted_other_invoice_items
    other_invoice_items.sort_by(&:position)
  end
  
  def can_be_factorised?
    customer = order ? order.customer : nil
    return false unless customer and invoice_type
    return customer.factorised? && invoice_type.factorisable
  end
  
  # return if invoice is currently associated to all order's delivery_notes without confirmed invoice
  def associated_to_all_delivery_notes_without_confirmed_invoice?
    ( order.delivery_notes_without_confirmed_invoice - delivery_note_invoices.reject(&:should_destroy?).collect(&:delivery_note) ).empty?
  end
  
  def associated_to_all_services_without_confirmed_invoice?
    ( order.orders_service_deliveries_without_confirmed_invoice - service_invoice_items.reject(&:should_destroy?).collect(&:invoiceable) ).empty?
  end
  
  def signed_quote
    order && order.signed_quote
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total
    invoice_items.reject(&:should_destroy?).collect(&:total).compact.sum
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total_with_taxes
    invoice_items.reject(&:should_destroy?).collect(&:total_with_taxes).compact.sum
  end
  
  alias_method :net_to_paid, :total_with_taxes
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def summon_of_taxes
    total_with_taxes - total
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def tax_coefficients
    invoice_items.reject(&:should_destroy?).collect(&:vat).compact.uniq
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total_taxes_for(coefficient)
    invoice_items.reject(&:should_destroy?).select{ |i| i.vat == coefficient }.collect(&:total).compact.sum
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def number_of_pieces
    invoice_items.reject(&:should_destroy?).collect(&:quantity).compact.sum
  end
  
  def number_of_products
    invoice_items.reject(&:should_destroy?).count
  end
  
  def number_of_due_dates
    due_dates.reject(&:should_destroy?).count
  end
  
  def already_paid_amount
    due_dates.collect{ |d| d.total_amounts }.sum
  end
  
  def balance_to_be_paid #TODO test if 'to_f' don't fail the calculation
    ( net_to_paid.to_f.round_to(2) - already_paid_amount.to_f.round_to(2) ) # without 'round_to', the 2 values can be different with very very small variation (eg: 7.27595761418343e-12)
  end
  
  def really_totally_paid?
    balance_to_be_paid == 0
  end
  
  def build_or_update_free_invoice_item_for_deposit_invoice
    return nil unless deposit and deposit_amount and deposit_vat
    new_attributes = {  :invoiceable_id => nil,
                        :quantity       => 1,
                        :unit_price     => deposit_amount_without_taxes,
                        :vat            => deposit_vat,
                        :name           => "Acompte de #{deposit}% pour avance sur chantier",
                        :description    => deposit_comment }
    
    free_invoice_item = free_invoice_items.first || invoice_items.build
    free_invoice_item.attributes = new_attributes
  end
  
  def build_or_update_invoice_items_from(delivery_note, should_destroy = false)
    return if delivery_note.nil? or delivery_note.new_record?
    
    delivery_note.delivery_note_items.each do |dn_item|
      existing_invoice_item = product_invoice_items.detect{ |i| i.invoiceable_id == dn_item.end_product_id }
      
      if should_destroy
        existing_invoice_item.quantity -= dn_item.really_delivered_quantity if existing_invoice_item
      else
        if existing_invoice_item
          existing_invoice_item.quantity += dn_item.really_delivered_quantity unless delivery_notes.reject(&:new_record?).collect(&:id).include?(delivery_note.id)
        elsif dn_item.really_delivered_quantity > 0
          invoice_items.build( :invoiceable_id    => dn_item.end_product_id,
                               :invoiceable_type  => dn_item.end_product.class.name,
                               :quantity          => dn_item.really_delivered_quantity )
        end
      end
    end
  end
  
  def build_or_update_invoice_items_from_associated_delivery_notes
    return unless order
    
    # build or update invoice_items
    delivery_note_invoices.reject(&:should_destroy?).collect(&:delivery_note).each do |delivery_note|
      build_or_update_invoice_items_from(delivery_note)
    end
    
    # mark for destroy invoice_items
    delivery_note_invoices.select(&:should_destroy?).collect(&:delivery_note).each do |delivery_note|
      build_or_update_invoice_items_from(delivery_note, true)
    end
  end
  
  #TODO test this method
  def build_service_invoice_items_from_unbilled_orders_service_deliveries
    return unless order
    
    order.orders_service_deliveries_without_confirmed_invoice.each do |osd|
      invoice_items.build(:invoiceable_id   => osd.id,
                          :invoiceable_type => osd.class.name,
                          :quantity         => osd.quantity)
    end
  end
  
  # attributes = array of ids of delivery_notes to associate => ["1","2"]
  def delivery_note_invoice_attributes=(ids)
    # mark delivery_note_invoice for destroy if the element is not in the array
    delivery_note_invoices.each do |i|
      i.should_destroy = true unless ids.map(&:to_s).include?(i.delivery_note_id.to_s)
    end
    
    # build delivery_note_invoice
    for id in ids
      id = id.to_i
      delivery_note_invoices.build(:delivery_note_id => id) unless delivery_note_invoices.detect{ |x| x.delivery_note_id == id }
    end
  end
  
  def save_delivery_note_invoices
    delivery_note_invoices.each do |i|
      if i.new_record?
        i.save(false)
      elsif i.should_destroy?
        i.destroy
      end
    end
  end
  
  def free_invoice_item_attributes=(invoice_item_attributes)
    invoice_item_attributes.each do |attributes|
      build_or_update_invoice_item(attributes)
    end
  end
  
  def product_invoice_item_attributes=(invoice_item_attributes)
    invoice_item_attributes.each do |attributes|
      build_or_update_invoice_item(attributes)
    end
  end
  
  #TODO test this method
  def service_invoice_item_attributes=(invoice_item_attributes)
    invoice_item_attributes.each do |attributes|
      build_or_update_invoice_item(attributes)
    end
  end
  
  def save_invoice_items
    return if confirmed_at_was

    invoice_items.each do |i|
      if i.should_destroy?
        i.destroy
      else
        i.save(false)
      end
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
    return if confirmed_at_was #protect due_dates from changes if invoice is confirmed #OPTIMIZE is this really used and right ?
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
    if factoring_paid? or due_date_paid? or totally_paid?
      the_due_date_to_pay.save(false) if the_due_date_to_pay
    end
  end
  
  def confirm
    if can_be_confirmed?
      update_reference
      self.published_on ||= Date.today
      self.confirmed_at   = Time.now
      self.status         = STATUS_CONFIRMED
      self.save
    else
      false
    end
  end
  
  def cancel(attributes)
    if can_be_cancelled?
      self.attributes   = attributes
      self.cancelled_at = Time.now
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
  
  def abandon(attributes)
    if can_be_abandoned?
      self.attributes   = attributes
      self.abandoned_on = Date.today
      self.status       = STATUS_ABANDONED
      self.save
    else
      false
    end
  end
  
  def factoring_pay(attributes)
    if can_be_factoring_paid?
      self.due_date_to_pay  = attributes[:due_date_to_pay]
      self.status           = STATUS_FACTORING_PAID
      self.save
    else
      false
    end
  end
  
  def factoring_recover(attributes)
    if can_be_factoring_recovered?
      self.attributes = attributes
      self.status     = STATUS_FACTORING_RECOVERED
      self.save
    else
      false
    end
  end
  
  def factoring_balance_pay(attributes)
    if can_be_factoring_balance_paid?
      self.attributes = attributes
      self.status     = STATUS_FACTORING_BALANCE_PAID
      self.save
    else
      false
    end
  end
  
  def due_date_pay(attributes)
    if can_be_due_date_paid?
      self.due_date_to_pay  = attributes[:due_date_to_pay]
      self.status           = STATUS_DUE_DATE_PAID
      self.save
    else
      false
    end
  end
  
  def totally_pay(attributes)
    if can_be_totally_paid?
      self.due_date_to_pay  = attributes[:due_date_to_pay]
      self.status           = STATUS_TOTALLY_PAID
      self.save
    else
      false
    end
  end
  
  #TODO test this method
  def invoice_step_open?
    order && order.invoicing_step && order.invoicing_step.invoice_step && !order.invoicing_step.invoice_step.terminated?
  end
  
  def factorised?
    factor_id
  end
  
  def was_factorised?
    factor_id_was
  end
  
  def deposit_invoice?
    invoice_type.name == DEPOSITE_INVOICE if invoice_type
  end
  
  def status_invoice?
    invoice_type.name == STATUS_INVOICE if invoice_type
  end
  
  def balance_invoice?
    invoice_type.name == BALANCE_INVOICE if invoice_type
  end
  
  def asset_invoice?
    invoice_type.name == ASSET_INVOICE if invoice_type
  end
  
  def calculate_deposit_amount_according_to_quote_and_deposit
    return unless signed_quote and deposit
    signed_quote.net_to_paid * deposit / 100
  end
  
  def deposit_amount_without_taxes
    return deposit_amount if deposit_amount.nil? or deposit_amount == 0 or deposit_vat.nil? or deposit_vat == 0
    deposit_amount / ( 1 + ( deposit_vat / 100 ) )
  end
  
  def can_create_deposit_invoice?
    signed_quote and order.deposit_invoice.nil? and order.balance_invoice.nil?
  end
  
  def can_create_status_invoice?
    signed_quote and order.balance_invoice.nil?
  end
  
  def can_create_balance_invoice?
    order and order.all_is_delivered? and order.balance_invoice.nil?
  end
  
  def can_create_asset_invoice?
    !signed_quote.nil?
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
  
  def factoring_balance_paid?
    status == STATUS_FACTORING_BALANCE_PAID
  end
  
  def due_date_paid?
    status == STATUS_DUE_DATE_PAID
  end
  
  def totally_paid?
    status == STATUS_TOTALLY_PAID
  end
  
  #TODO test and check if it's correct!!
  def factoring_payment
    return unless was_factorised?
    #due_dates.collect{ |d| d.payments.detect(&:paid_by_factor?) }.first
    due_dates.first.payments.first
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
  
  def was_factoring_balance_paid?
    status_was == STATUS_FACTORING_BALANCE_PAID
  end
  
  def was_due_date_paid?
    status_was == STATUS_DUE_DATE_PAID
  end
  
  def was_totally_paid?
    status_was == STATUS_TOTALLY_PAID
  end
  
  def was_totally_paid_on
    due_dates.last.payments.reject(&:new_record?).last.paid_on if was_totally_paid?
  end
  
  def can_be_added?
    invoice_step_open? and invoice_type and send("can_create_#{invoice_type.name}?")
  end
  
  def can_be_edited?
    !new_record? and was_uncomplete? and invoice_step_open?
  end
  
  def can_be_downloaded? # with PDF generator
    reference_was
  end
  
  def can_be_deleted?
    !new_record? and was_uncomplete? and invoice_step_open?
  end
  
  def can_be_confirmed?
    !new_record? and was_uncomplete? and invoice_step_open?
  end
  
  def can_be_cancelled?
    !new_record? and ( was_confirmed? or was_sended? ) and invoice_step_open?
  end
  
  def can_be_sended?
    was_confirmed? and invoice_step_open?
  end
  
  def can_be_abandoned?
    ( was_factorised? and was_factoring_recovered? ) or ( !was_factorised? and ( was_sended? or was_due_date_paid? ) ) and invoice_step_open?
  end
  
  def can_be_factoring_paid?
    was_factorised? and was_sended? and invoice_step_open?
  end
  
  def can_be_factoring_recovered?
    was_factoring_paid? and invoice_step_open?
  end
  
  def can_be_factoring_balance_paid?
    invoice_step_open? and was_factoring_paid? or was_factoring_recovered? or ( was_factorised? and was_abandoned? )
  end
  
  def can_be_due_date_paid?
    invoice_step_open? and !was_factorised? and ( was_sended? or was_due_date_paid? or was_abandoned? ) and unpaid_due_dates.count > 1
  end
  
  def can_be_totally_paid?
    invoice_step_open? and !was_factorised? and ( was_sended? or was_due_date_paid? or was_abandoned? ) and unpaid_due_dates.count == 1
  end
  
  def dunning_level
    #TODO
  end
  
  def unpaid_amount
    #TODO
  end
  
  def order_and_customer_contacts
    order ? order.all_contacts_and_customer_contacts : []
  end
  
  def priority_level #TODO priority_level should take in account the dunnings
    return unless published_on and upcoming_due_date and upcoming_due_date.date
    
    today       = Date.today
    last_limit  = upcoming_due_date.date
    delay       = (last_limit - published_on) / 3
    
    first_limit   = published_on  + delay
    second_limit  = published_on  + (2 * delay)
    
    return VERY_LOW_PRIORITY  if today <= first_limit
    return LOW_PRIORITY       if today > first_limit and today < second_limit
    return MEDIUM_PRIORITY    if today > second_limit and today < last_limit
    return HIGH_PRIORITY      if today >= last_limit
  end
  
  def message_for_validates_date_cancelled_at_on_or_after_while_confirmed
    message_for_validates_date("cancelled_at", "on_or_after", "while_confirmed", self.published_on)
  end
  
  def message_for_validates_date_cancelled_at_on_or_after_while_sended
    message_for_validates_date("cancelled_at", "on_or_after", "while_sended", self.sended_on)
  end
  
  def message_for_validates_date_abandoned_on_on_or_after_while_sended
    message_for_validates_date("abandoned_on", "on_or_after", "while_sended", self.sended_on)
  end
  
  def message_for_validates_date_abandoned_on_on_or_after_while_factoring_recovered
    message_for_validates_date("abandoned_on", "on_or_after", "while_factoring_recovered", self.factoring_recovered_on)
  end
  
  def message_for_validates_date_factoring_balance_paid_on_on_or_after_while_abandoned
    message_for_validates_date("factoring_balance_paid_on", "on_or_after", "while_abandoned", self.factoring_recovered_on)
  end
  
  def message_for_validates_date_factoring_balance_paid_on_on_or_after_while_factoring_paid
    message_for_validates_date("factoring_balance_paid_on", "on_or_after", "while_factoring_paid", self.factoring_paid_on)
  end
  
  def message_for_validates_date_factoring_balance_paid_on_on_or_after_on_while_factoring_recovered
    message_for_validates_date("factoring_balance_paid_on", "on_or_after", "while_factoring_recovered", self.factoring_recovered_on)
  end
    
  private
    def message_for_validates_date(attribute, error_type, context, restriction)
      I18n.t("activerecord.errors.models.invoice.attributes.#{attribute}.#{error_type}.#{context}", :restriction => restriction)
    end
    
    def build_or_update_invoice_item(attributes)
      if attributes[:id].blank?
        invoice_item = invoice_items.build(attributes) unless attributes[:should_destroy].to_i == 1
      else
        invoice_item = invoice_items.detect { |x| x.id == attributes[:id].to_i }
        invoice_item.attributes = attributes
      end
      
      return invoice_item
    end
end
