class Quotation < ActiveRecord::Base
  include QuoteBase

  STATUS_SIGNED     = 0
  STATUS_SENT       = 1
  STATUS_CANCELLED  = 2
  STATUS_REVOKED    = 3
  
  REQUESTS_PER_PAGE = 5
  
  VALIDITY_DELAY_UNITS = { 'heures' => 'hours',
                           'jours'  => 'days',
                           'mois'   => 'months' }
  
  has_permissions :as_business_object
  has_reference :prefix => :purchases
  
  has_many :quotation_supplies, :dependent => :delete_all, :order => 'position'
  has_many :existing_quotation_supplies, :class_name => "QuotationSupply", :conditions => ["supply_id IS NOT NULL"]
  has_many :free_quotation_supplies, :class_name => "QuotationSupply", :conditions => ["supply_id IS NULL"]
  has_many :supplier_supplies, :finder_sql => 'SELECT DISTINCT s.* FROM supplier_supplies s INNER JOIN (quotation_supplies t) ON (t.quotation_id = #{id}) WHERE (s.supplier_id = #{supplier_id} AND s.supply_id = t.supply_id)'
  
  has_one :purchase_order

  belongs_to :supplier
  belongs_to :creator, :class_name => "User"
  belongs_to :quotation_document, :class_name => "PurchaseDocument"
  belongs_to :canceller, :class_name => "User", :foreign_key => :canceller_id
  belongs_to :quotation_request
  belongs_to :forwarder
  
  validates_date :signed_on,  :on_or_before => Date.today,
                              :on_or_before_message  => :message_error_for_date_signed_after_today,
                              :if => :signed_or_sent?

  validates_date :sent_on,  :on_or_before => Date.today,
                            :on_or_before_message  => :message_error_for_date_sent_after_today,
                            :if => :sent?

  with_options :if => :cancelled? do |q|
    q.validates_presence_of :cancellation_comment, :canceller_id
    q.validates_presence_of :canceller, :if => :canceller_id
  end

  validates_presence_of :creator_id, :quotation_document
  validates_presence_of :supplier_id, :unless => :quotation_request_id
  validates_presence_of :creator, :if => :creator_id
  validates_presence_of :supplier, :if => :supplier_id
  
  validate :validates_similarity_of_supplier, :if => :quotation_request
  
  validates_inclusion_of :validity_delay_unit, :in => VALIDITY_DELAY_UNITS.values
  validates_inclusion_of :status, :in => [ STATUS_SIGNED, STATUS_SENT ], :allow_nil => true, :if => :new_record?
  validates_inclusion_of :status, :in => [ STATUS_REVOKED, STATUS_SIGNED, STATUS_SENT, STATUS_CANCELLED ], :allow_nil => true, :if => :was_drafted?
  validates_inclusion_of :status, :in => [ STATUS_SENT, STATUS_CANCELLED ], :if => :was_signed?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED ], :if => :was_sent?
  validates_inclusion_of :status, :in => [ STATUS_SIGNED, STATUS_SENT ], :allow_nil => true, :if => :was_cancelled?

  validates_length_of :quotation_supplies, :minimum => 1, :message => :length_of
  
  validates_associated :quotation_supplies, :quotation_document
  
  before_validation :build_missing_supplier_supplies
  
  after_save :save_quotation_supplies, :save_missing_supplier_supplies, :revoke_related_quotation_requests_and_quotations, :revoke_quotation_request
  
  before_destroy :can_be_destroyed?
  
  def validates_similarity_of_supplier
     errors.add(:supplier_id, message_error_for_similarity_of_supplier) unless supplier_id == quotation_request.supplier_id
  end
  
  def validity_delay_unit
    self[:validity_delay_unit] ||= 'hours'
  end
  
  def miscellaneous # for compatibility with quote_base.rb
    self[:miscellaneous]
  end
  
  def discount # for compatibility with quote_base.rb
    0
  end
  
  alias_method :product_quote_items, :quotation_supplies # for compatibility with quote_base.rb
  alias_method :carriage_costs, :miscellaneous # for compatibility with quote_base.rb
  
  def signed_or_sent?
    signed? or sent?
  end
  
  def should_revoke_related_quotation_requests_and_quotations?
    quotation_request ? (signed? || sent?) : false
  end
  
  def drafted?
    !new_record? and status.nil? and !revoked?
  end
  
  def signed?
    status == STATUS_SIGNED and !revoked?
  end
  
  def sent?
    status == STATUS_SENT and !revoked?
  end
  
  def cancelled?
    quotation_request ? (quotation_request.cancelled? or status == STATUS_CANCELLED) : status == STATUS_CANCELLED
  end
  
  def revoked?
#    quotation_request ? quotation_request.revoked? : false
    status == STATUS_REVOKED
  end
  
  def was_drafted?
    !new_record? and status_was.nil? and !was_revoked?
  end
  
  def was_signed?
    status_was == STATUS_SIGNED and !was_revoked?
  end
  
  def was_sent?
    status_was == STATUS_SENT and !was_revoked?
  end
  
  def was_cancelled?
    quotation_request ? (quotation_request.was_cancelled? or status_was == STATUS_CANCELLED) : status_was == STATUS_CANCELLED
  end
  
  def was_revoked?
#    quotation_request ? quotation_request.was_revoked? : false
    status_was == STATUS_REVOKED
  end
  
  def can_be_signed?
    (new_record? or was_drafted? or was_cancelled?) and !quotation_document.nil?
  end
  
  def can_be_sent?
    !was_revoked? and !was_sent? and !quotation_document.nil?
  end
  
  def can_be_drafted_from_cancelled?
    was_cancelled? and (!signed_on_was and !sent_on_was) # OPTIMIZE : dates will be journalized
  end
  
  def can_be_associated_with_a_purchase_order?
    (was_signed? or was_sent?) and !purchase_order
  end
  
  def can_be_edited?
    was_drafted?
  end
  
  def can_be_cancelled?
    !was_cancelled? and !purchase_order
  end
  
  def can_be_destroyed?
    was_drafted?
  end
  
  def can_be_revoked?
    was_drafted?
  end
  
  def sign
    if can_be_signed?
      self.status = STATUS_SIGNED
      return self.save
    end
    false
  end
  
  def send_to_supplier
    if can_be_sent?
      self.status = STATUS_SENT
      return self.save
    end
    false
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED
      return self.save
    end
    false
  end
  
  def revoke
    if can_be_revoked?
      self.revoked_at = Time.now
      self.status = STATUS_REVOKED
      return self.save
    end
    false
  end
  
  
  # TODO test this method
  def draft_from_cancelled
    if can_be_drafted_from_cancelled?
      self.cancelled_at = nil
      self.cancelled_comment = nil
      self.canceller_id = nil
      self.status = nil
      return self.save
    end
    false
  end
  
  def quotation_document_attributes=(quotation_document_attributes)
    self.quotation_document = PurchaseDocument.new(quotation_document_attributes.first)
  end
  
  def build_missing_supplier_supplies
    quotation_supplies.each do |qs|
      unless SupplierSupply.find_by_supplier_id_and_supply_id(supplier_id, qs.supply_id)
        supplier_supplies.build(:supplier_id          => supplier_id,
                                :supply_id            => qs.supply_id,
                                :supplier_reference   => qs.supplier_reference,
                                :supplier_designation => qs.supplier_designation,
                                :fob_unit_price       => qs.unit_price,
                                :taxes                => qs.taxes)
      end
    end
  end
  
  def save_missing_supplier_supplies
    supplier_supplies.each{|s| s.save(false)}
  end
  
  def save_quotation_supplies
    quotation_supplies.each do |e|
      unless e.should_destroy.to_i == 1
        e.save(false)
      end
    end
  end
  
  def quotation_supplies_attributes=(quotation_supplies_attributes)
    quotation_supplies_attributes.each do |quotation_supply_attributes|
      if quotation_supply_attributes[:id].blank?
        quotation_supplies.build(quotation_supply_attributes)
      else
        quotation_supply = quotation_supplies.detect { |t| t.id == quotation_supply_attributes[:id].to_i }
        quotation_supply.attributes = quotation_supply_attributes
      end
    end
  end
  
  def quotation_document_attributes=(quotation_document_attributes)
    self.quotation_document = PurchaseDocument.new(quotation_document_attributes.first)
  end
  
  
  def message_error_for_date_signed_after_today
    message_for_validates("signed_on", "on_or_before", Date.today)
  end
  
  def message_error_for_date_sent_after_today
    message_for_validates("sent_on", "on_or_before", Date.today)
  end
  
  def message_error_for_similarity_of_supplier
    message_for_validates("supplier_id", "similarity_of_supplier")
  end
  
#  private
    def revoke_quotation_request
      quotation_request.revoke if quotation_request and !quotation_request.was_cancelled? and !quotation_request.was_revoked? and cancelled?
    end

    def revoke_related_quotation_requests_and_quotations
      quotation_request.revoke_related_quotation_requests_and_quotations if should_revoke_related_quotation_requests_and_quotations?
    end
    
    def message_for_validates(attribute, error_type, restriction = "")
      I18n.t("activerecord.errors.models.#{self.class.name.tableize.singularize}.attributes.#{attribute}.#{error_type}", :restriction => restriction)
    end
end
