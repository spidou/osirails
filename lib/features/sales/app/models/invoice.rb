class Invoice < ActiveRecord::Base
  # status
  STATUS_CONFIRMED              = 'confirmed'
  STATUS_CANCELLED              = 'cancelled'
  STATUS_SENDED                 = 'sended'
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
  
  REFERENCE_PATTERN = "%Y%m" # 1 Jan 2009 => 200901
  
  has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :factoring_recover, :factoring_balance_pay, :due_date_pay, :totally_pay ]
  has_contact :accept_from => :order_contacts
  has_address :bill_to_address
  
  belongs_to :order
  belongs_to :factor
  belongs_to :invoice_type
  belongs_to :send_invoice_method
  belongs_to :creator,      :class_name => 'User'
  belongs_to :cancelled_by, :class_name => "User"
  belongs_to :abandoned_by, :class_name => "User"
  
  has_many :invoice_items,  :dependent  => :destroy
  has_many :products,       :through    => :invoice_items
  
  has_many :delivery_note_invoices, :dependent  => :destroy
  has_many :delivery_notes,         :through    => :delivery_note_invoices
  
  has_many :due_dates, :order => "date ASC",  :dependent => :destroy
  
  has_many :dunnings, :as => :has_dunning, :order => "created_at DESC"
  
  attr_accessor :the_due_date_to_pay # only one due_date can be paid at time, and it's stored in this accessor
  
  validates_associated :invoice_items, :products, :delivery_note_invoices, :delivery_notes, :dunnings, :due_dates
  
  # when invoice is UNSAVED
  with_options :if => :new_record? do |x|
    x.validates_inclusion_of :status, :in => [ nil ]
  end
  
  # when invoice is UNCOMPLETE
  with_options :if => :was_uncomplete? do |x|
    x.validates_inclusion_of :status, :in => [ nil, STATUS_CONFIRMED ]
    x.validates_persistence_of :order_id, :invoice_type_id, :creator_id
  end
  
  # when invoice is UNSAVED or UNCOMPLETE
  with_options :if => Proc.new{ |invoice| invoice.new_record? or invoice.was_uncomplete? } do |x|
    x.validates_presence_of :bill_to_address, :published_on, :invoice_type_id, :creator_id
    x.validates_presence_of :invoice_type,  :if => :invoice_type_id
    x.validates_presence_of :creator,       :if => :creator_id
    
    x.validates_length_of :contact_ids, :minimum => 1
    
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
    
    x.validates_date :confirmed_at, :on_or_after         => :created_at,
                                    :on_or_after_message => "ne doit pas être AVANT la date de création de la facture&#160;(%s)"
    x.validates_date :published_on, :on_or_after         => Proc.new{ |i| i.associated_quote.signed_on },
                                    :on_or_after_message => "ne doit pas être AVANT la date de signature du devis&#160;(%s)"
  end
  
  # when invoice is CONFIRMED
  with_options :if => :was_confirmed? do |x|
    x.validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_SENDED ]
  end
  
  # when invoice is CONFIRMED and above
  with_options :if => :confirmed_at_was do |x|
    x.validates_persistence_of :confirmed_at, :published_on, :reference, :factor_id, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :contact
  end
  
  ### while invoice CANCELLATION
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.cancelled? } do |x|
    x.validates_presence_of :cancelled_at, :cancelled_comment, :cancelled_by_id
    x.validates_presence_of :cancelled_by, :if => :cancelled_by_id
    
    x.validates_date :cancelled_at, :on_or_after         => :published_on,
                                    :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
  end
  
  ### while invoice SENDING
  with_options :if => Proc.new{ |i| i.confirmed_at_was and i.sended? } do |x|
    x.validates_presence_of :sended_on, :send_invoice_method_id
    x.validates_presence_of :send_invoice_method, :if => :send_invoice_method_id
    
    x.validates_date :sended_on,  :on_or_after         => :published_on,
                                  :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
    x.validates_date :sended_on,  :on_or_before        => Date.today,
                                  :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
  end
  
  # when invoice is CANCELLED
  with_options :if => :was_cancelled? do |x|
    x.validates_persistence_of :status, :cancelled_at, :cancelled_comment, :cancelled_by_id
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
    x.validates_persistence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
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
                                                 :on_or_after_message => "ne doit pas être AVANT la date de définancement de la facture&#160;(%s)"
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
    
    x.validates_date :factoring_recovered_on, :on_or_after         => :factoring_paid_on,
                                              :on_or_after_message => "ne doit pas être AVANT la date de réglement par le factor de la facture&#160;(%s)"
  end
  
  ### while invoice FACTORING_BALANCE_PAYING
  with_options :if => Proc.new{ |i| i.factoring_paid_on_was and i.factoring_balance_paid? } do |x|
    x.validates_presence_of :factoring_balance_paid_on
    
    x.validates_date :factoring_balance_paid_on, :on_or_after         => :factoring_paid_on,
                                                 :on_or_after_message => "ne doit pas être AVANT la date de règlement par le factor de la facture&#160;(%s)"
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
    x.validates_presence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
    x.validates_presence_of :abandoned_by, :if => :abandoned_by_id
    
    x.validates_date :abandoned_on, :on_or_after         => :factoring_recovered_on,
                                    :on_or_after_message => "ne doit pas être AVANT la date de définancement de la facture&#160;(%s)"
  end
  
  ### while invoice FACTORING_BALANCE_PAYING
  with_options :if => Proc.new{ |i| i.factoring_recovered_on_was and i.factoring_balance_paid? } do |x|
    x.validates_presence_of :factoring_balance_paid_on
    
    x.validates_date :factoring_balance_paid_on, :on_or_after         => :factoring_recovered_on,
                                                 :on_or_after_message => "ne doit pas être AVANT la date de définancement de la facture&#160;(%s)"
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
  
  validate :validates_presence_of_associated_quote
  
  validate :validates_factorised_according_to_invoice_type
  validate :validates_product_items_according_to_invoice_type
  validate :validates_free_items_according_to_invoice_type
  validate :validates_invoice_items_according_to_invoice_type
  validate :validates_delivery_note_invoices_according_to_invoice_type
  
  validate :validates_uniqueness_of_due_dates_with_factorised_invoice
  validate :validates_due_date_amounts
  validate :validates_due_date_dates
  validate :validates_payment_dates
  validate :validates_payment_payment_methods
  validate :validates_due_date_payment_amounts_equal_to_net_to_paid
  
  validate :validates_no_new_payments_unless_when_factoring_pay_or_totally_pay
  
  validate :validates_integrity_of_product_items
  
  attr_protected :status, :reference, :cancelled_by, :abandoned_by, :confirmed_at, :cancelled_at
  
  before_validation :build_or_update_free_item_for_deposit_invoice
  
  after_save :save_invoice_items, :save_due_dates, :save_due_date_to_pay, :save_delivery_note_invoices
  
  before_destroy :can_be_deleted?
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:created_at]                  = 'Créée le :'
  @@form_labels[:creator]                     = 'Par :'
  @@form_labels[:status]                      = 'État actuel :'
  @@form_labels[:invoice_type]                = 'Type de facture :'
  @@form_labels[:published_on]                = "Date d'émission :"
  @@form_labels[:factor]                      = 'Factor :'
  @@form_labels[:sended_on]                   = 'Envoyée au client le :'
  @@form_labels[:send_invoice_method]         = 'Par :'
  @@form_labels[:cancelled_at]                = 'Annulée le :'
  @@form_labels[:cancelled_by]                = 'Par :'
  @@form_labels[:cancelled_comment]           = 'Indiquer la raison de cette annulation :'
  @@form_labels[:abandoned_on]                = 'Abandonée le :'
  @@form_labels[:abandoned_by]                = 'Par :'
  @@form_labels[:abandoned_comment]           = "Indiquer la raison de l'abandon :"
  @@form_labels[:net_to_paid]                 = 'Montant total de la facture :'
  @@form_labels[:factoring_paid_on]           = 'Financement du Factor le :'
  @@form_labels[:factoring_recovered_on]      = 'Définancement du Factor le :'
  @@form_labels[:factoring_recovered_comment] = 'Indiquer la raison du définancement :'
  @@form_labels[:factoring_balance_paid_on]   = 'Solde Factor reçu le :'
  @@form_labels[:delivery_note_invoices]      = 'Bons de livraison associés :'
  
  def validates_presence_of_associated_quote
    errors.add(:associated_quote, "La facture doit être associée à un devis signé, mais celui-ci n'est pas présent.") unless associated_quote
  end
  
  def validates_presence_of_factoring_payment
    errors.add(:factoring_payment, "Le réglement du factor est nécessaire pour continuer") unless factoring_payment
  end
  
  def validates_factorised_according_to_invoice_type
    errors.add(:factor_id, "Cette facture ne peut pas être factorisée car cela est incompatible avec le type de facture choisi ou parce que le client n'est pas factorisé") if factorised? and !can_be_factorised?
  end
  
  def validates_product_items_according_to_invoice_type
    if deposit_invoice?
      errors.add(:product_items, "Les lignes de produits de sont pas autorisées pour une facture d'acompte") unless product_items.empty?
    elsif status_invoice? or balance_invoice?
      invoice_type_text = status_invoice? ? 'situation' : 'solde'
      errors.add(:product_items, "Les lignes de produits sont obligatoires pour une facture de #{invoice_type_text}") if product_items.empty?
    end
  end
  
  def validates_free_items_according_to_invoice_type
    if deposit_invoice?
      errors.add(:free_items, "Une facture d'acompte doit contenir au moins une ligne (libre)") if free_items.empty?
    end
  end
  
  def validates_invoice_items_according_to_invoice_type
    if asset_invoice?
      errors.add(:invoice_items, "Une facture d'avoir doit contenir au moins une ligne (libre)") if invoice_items.empty?
    end
  end
  
  def validates_delivery_note_invoices_according_to_invoice_type
    if deposit_invoice? or asset_invoice?
      invoice_type_text = deposit_invoice? ? 'acompte' : 'avoir'
      errors.add(:delivery_note_invoices, "Une facture d'#{invoice_type_text} ne peut pas être associée à un Bon de Livraison") unless delivery_note_invoices.empty?
    elsif status_invoice?
      errors.add(:delivery_note_invoices, "Une facture de situation doit être associée à au moins 1 Bon de Livraison") if delivery_note_invoices.empty?
      errors.add(:delivery_note_invoices, "Une facture de situation ne doit PAS être associée à l'ensemble des Bons de Livraison restants à facturer. Vous devez changer le type de facture et choisir la facture de solde") if order.all_is_delivered? and associated_to_all_unbilled_delivery_notes?
    elsif balance_invoice?
      errors.add(:delivery_note_invoices, "Une facture de solde doit absolument être associée à l'ensemble des Bons de Livraison restants à facturer") unless associated_to_all_unbilled_delivery_notes?
    end
  end
  
  def validates_presence_of_deposit_attributes
    return true unless deposit_invoice?
    errors.add(:deposit, ActiveRecord::Errors::default_error_messages[:not_a_number]) unless deposit and deposit > 0
    errors.add(:deposit_amount, ActiveRecord::Errors::default_error_messages[:not_a_number]) unless deposit_amount and deposit_amount > 0
    errors.add(:deposit_vat, ActiveRecord::Errors::default_error_messages[:not_a_number]) unless deposit_vat and deposit_vat > 0
  end
  
  def validates_invoice_type
    return unless self.new_record?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture d'acompte pour cette commande") if deposit_invoice? and !can_create_deposit_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture de situation pour cette commande") if status_invoice? and !can_create_status_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture de solde pour cette commande") if balance_invoice? and !can_create_balance_invoice?
    errors.add(:invoice_type, "Vous ne pouvez pas/plus créer de facture d'avoir pour cette commande") if asset_invoice? and !can_create_asset_invoice?
  end
  
  def validates_presence_of_at_least_one_due_date
    errors.add(:due_dates, "Une facture doit avoir au moins une échéance") if due_dates.empty?
  end
  
  def validates_due_dates_payments_before_totally_pay
    errors.add(:due_dates, "La somme des règlements des échéances ne correspond pas au montant total de la facture (#{net_to_paid.round_to(2)} - #{already_paid_amount.round_to(2)} = #{net_to_paid.round_to(2) - already_paid_amount.round_to(2)})") unless really_totally_paid?
  end
  
  def validates_uniqueness_of_due_dates_with_factorised_invoice
    errors.add(:due_dates, "Une facture factorisée ne peut avoir qu'une seule échéance") if factorised? and due_dates.reject(&:should_destroy?).size > 1 #TODO reject(&:should_destroy?) have just been added => write or modify tests for that method to take it in account
  end
  
  #TODO write tests
  def validates_due_date_amounts
    errors.add(:due_dates, "La somme des montants des échéances ne correspond pas au montant total de la facture (#{total_of_due_dates} ≠ #{net_to_paid})") unless total_of_due_dates_equal_to_net_to_paid?
  end
  
  # write tests
  def validates_upcoming_due_date_payments_before_due_date_pay
    return unless due_date = upcoming_due_date
    due_date.errors.add(:payments, "Vous devez ajouter au moins un règlement à la prochaine échéance pour continuer") if due_date.payments.empty?
  end
  
  # write tests
  def validates_due_date_payment_amounts_equal_to_net_to_paid
    return if factorised?
    
    for due_date in due_dates
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
    
    for due_date in due_dates
      due_date.errors.add(:date, "ne doit pas être AVANT la date d'émission de la facture (#{self.published_on.humanize})") if due_date.date and due_date.date < published_on
    end
    
    errors.add(:due_dates) unless due_dates.reject{ |d| d.errors.empty? }.empty?
  end
  
  #TODO write tests
  def validates_payment_dates
    return unless published_on_was
    
    for due_date in due_dates
      for payment in due_date.payments
        if payment.paid_on
          payment.errors.add(:paid_on, "ne doit pas être AVANT la date d'émission de la facture&#160;(#{self.published_on.humanize})") if payment.paid_on < published_on
          payment.errors.add(:paid_on, "ne doit pas être APRÈS aujourd'hui&#160;(#{Date.today.humanize})") if payment.paid_on > Date.today
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
          payment.errors.add(:payment_method_id, ActiveRecord::Errors::default_error_messages[:blank])
        else
          payment.errors.add(:payment_method, ActiveRecord::Errors::default_error_messages[:blank]) unless payment.payment_method
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
  
  def validates_integrity_of_product_items
    return unless status_invoice? or balance_invoice?
    
    delivery_note_items_sum = {}
    delivery_note_invoices.reject(&:should_destroy).collect(&:delivery_note).collect(&:delivery_note_items).flatten.each do |i|
      p_id = i.quote_item.product_id
      ( delivery_note_items_sum[p_id] = ( delivery_note_items_sum[p_id] || 0 ) + i.quantity ) if i.quantity > 0
    end
    
    product_items_sum = {}
    product_items.each{ |i| product_items_sum[i.product_id] = i.quantity if i.quantity > 0 }
    
    errors.add(:invoice_items, "La liste des produits qui composent la facture est incorrecte. Elle ne correspond pas aux produits livrés dans le(s) 'Bon de Livraison' associé(s) (#{product_items_sum.inspect} - #{delivery_note_items_sum.inspect} = #{product_items_sum.diff(delivery_note_items_sum).inspect})") if product_items_sum != delivery_note_items_sum
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
  
  def product_items
    invoice_items.select(&:product_id)
  end
  
  def free_items
    invoice_items.reject(&:product_id)
  end
  
  def can_be_factorised?
    customer = order ? order.customer : nil
    return false unless customer and invoice_type
    return customer.factorised? && invoice_type.factorisable
  end
  
  # return if invoice is currently associated to all order's unbilled_delivery_notes
  def associated_to_all_unbilled_delivery_notes?
    ( order.unbilled_delivery_notes - delivery_note_invoices.reject(&:should_destroy?).collect(&:delivery_note) ).empty?
  end
  
  def associated_quote
    order ? order.signed_quote : nil
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total
    invoice_items.collect(&:total).sum
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total_with_taxes
    invoice_items.collect(&:total_with_taxes).sum
  end
  
  alias_method :net_to_paid, :total_with_taxes
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def summon_of_taxes
    total_with_taxes - total
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def tax_coefficients
    invoice_items.collect(&:vat).uniq
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def total_taxes_for(coefficient)
    invoice_items.select{ |i| i.vat == coefficient }.collect(&:total).sum
  end
  
  # OPTIMIZE this is a copy of an already existant method in quote.rb (invoice_items instead of quote_items collection)
  def number_of_pieces
    invoice_items.collect(&:quantity).sum
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
  
  def build_or_update_free_item_for_deposit_invoice
    return nil unless deposit and deposit_amount and deposit_vat
    new_attributes = {  :product_id   => nil,
                        :quantity     => 1,
                        :unit_price   => deposit_amount_without_taxes,
                        :vat          => deposit_vat,
                        :name         => "Acompte de #{deposit}% pour avance sur chantier",
                        :description  => deposit_comment }
    
    free_item = free_items.first || invoice_items.build
    free_item.attributes = new_attributes
  end
  
  def build_or_update_invoice_items_from(delivery_note, should_destroy = false)
    return if delivery_note.nil? or delivery_note.new_record?
    
    delivery_note.delivery_note_items.each do |item|
      existing_invoice_item = invoice_items.detect{ |i| i.product_id == item.quote_item.product_id }
      
      if should_destroy
        if existing_invoice_item
          existing_invoice_item.quantity -= item.really_delivered_quantity
        end
    else
        if existing_invoice_item
          existing_invoice_item.quantity += item.really_delivered_quantity if existing_invoice_item.new_record?
        elsif item.really_delivered_quantity > 0
          invoice_items.build( :product_id  => item.quote_item.product_id,
                               :quantity    => item.really_delivered_quantity )
        end
      end
    end
  end
  
  def build_or_update_invoice_items_from_associated_delivery_notes
    return unless order
    
    # build or update invoice_items
    #delivery_note_invoices.reject(&:should_destroy?).select(&:new_record?).collect(&:delivery_note).each do |delivery_note|
    delivery_note_invoices.reject(&:should_destroy?).collect(&:delivery_note).each do |delivery_note|
      build_or_update_invoice_items_from(delivery_note)
    end
    
    # mark for destroy invoice_items
    delivery_note_invoices.select(&:should_destroy?).collect(&:delivery_note).each do |delivery_note|
      build_or_update_invoice_items_from(delivery_note, true)
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
      self.attributes   = cancel_attributes
      self.cancelled_at = Time.now
      self.status       = STATUS_CANCELLED
      self.save
    else
      false
    end
  end
  
  def send_to_customer(send_attributes)
    if can_be_sended?
      self.attributes = send_attributes
      self.status     = STATUS_SENDED
      self.save
    else
      false
    end
  end
  
  def abandon(abandon_attributes)
    if can_be_abandoned?
      self.attributes   = abandon_attributes
      self.abandoned_on = Date.today
      self.status       = STATUS_ABANDONED
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
  
  def factoring_recover(factoring_recover_attributes)
    if can_be_factoring_recovered?
      self.attributes = factoring_recover_attributes
      self.status     = STATUS_FACTORING_RECOVERED
      self.save
    else
      false
    end
  end
  
  def factoring_balance_pay(factoring_balance_pay_attributes)
    if can_be_factoring_balance_paid?
      self.attributes = factoring_balance_pay_attributes
      self.status     = STATUS_FACTORING_BALANCE_PAID
      self.save
    else
      false
    end
  end
  
  def due_date_pay(due_date_attributes)
    if can_be_due_date_paid?
      self.due_date_to_pay  = due_date_attributes[:due_date_to_pay]
      self.status           = STATUS_DUE_DATE_PAID
      self.save
    else
      false
    end
  end
  
  def totally_pay(totally_pay_attributes)
    if can_be_totally_paid?
      self.due_date_to_pay  = totally_pay_attributes[:due_date_to_pay]
      self.status           = STATUS_TOTALLY_PAID
      self.save
    else
      false
    end
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
    return unless associated_quote and deposit
    associated_quote.net_to_paid * deposit / 100
  end
  
  def deposit_amount_without_taxes
    return deposit_amount if deposit_amount.nil? or deposit_amount == 0 or deposit_vat.nil? or deposit_vat == 0
    deposit_amount / ( 1 + ( deposit_vat / 100 ) )
  end
  
  def can_create_deposit_invoice?
    order and order.signed_quote and !order.deposit_invoice and ( !order.all_is_delivered? or ( order.all_is_delivered? and !order.all_signed_delivery_notes_are_billed? ) )
  end
  
  def can_create_status_invoice?
    unbilled_delivery_notes = order.unbilled_delivery_notes.count
    order and ( unbilled_delivery_notes > 1 or ( unbilled_delivery_notes == 1 and !order.all_is_delivered? ) )
  end
  
  def can_create_balance_invoice?
    order and order.all_is_delivered? and !order.all_signed_delivery_notes_are_billed?
  end
  
  def can_create_asset_invoice?
    associated_quote
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
    return false unless invoice_type
    return send("can_create_#{invoice_type.name}?")
  end
  
  def can_be_edited?
    !new_record? and was_uncomplete?
  end
  
  def can_be_deleted?
    !new_record? and was_uncomplete?
  end
  
  def can_be_confirmed?
    !new_record? and was_uncomplete?
  end
  
  def can_be_cancelled?
    !new_record? and ( was_confirmed? or was_sended? )
  end
  
  def can_be_sended?
    was_confirmed?
  end
  
  def can_be_abandoned?
    ( was_factorised? and was_factoring_recovered? ) or ( !was_factorised? and ( was_sended? or was_due_date_paid? ) )
  end
  
  def can_be_factoring_paid?
    was_factorised? and was_sended?
  end
  
  def can_be_factoring_recovered?
    was_factoring_paid?
  end
  
  def can_be_factoring_balance_paid?
    was_factoring_paid? or was_factoring_recovered? or ( was_factorised? and was_abandoned? )
  end
  
  def can_be_due_date_paid?
    !was_factorised? and ( was_sended? or was_due_date_paid? or was_abandoned? ) and unpaid_due_dates.count > 1
  end
  
  def can_be_totally_paid?
    !was_factorised? and ( was_sended? or was_due_date_paid? or was_abandoned? ) and unpaid_due_dates.count == 1
  end
  
  def dunning_level
    #TODO
  end
  
  def unpaid_amount
    #TODO
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
end
