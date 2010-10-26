class QuotationRequest < ActiveRecord::Base
  STATUS_CONFIRMED  = 0
  STATUS_CANCELLED  = 1
  STATUS_REVOKED    = 2
  
  QUOTATIONREQUESTS_PER_PAGE = 15
  
  has_contact :supplier_contact, :accept_from => :supplier_contacts #OPTIMIZE : would be better if could manage Proc in order to be able to add conditions
  has_permissions :as_business_object, :additional_class_methods => [:confirm, :cancel]
  has_reference :prefix => :purchases
  
  belongs_to :supplier
  belongs_to :creator, :class_name => "User"
  belongs_to :canceller, :class_name => "User", :foreign_key => :canceller_id
  belongs_to :employee
  belongs_to :parent, :class_name => "QuotationRequest", :foreign_key => :parent_id
  belongs_to :similar, :class_name => "QuotationRequest", :foreign_key => :similar_id
  
  has_many :quotation_request_supplies, :dependent => :delete_all, :order => 'position'
  has_many :children, :class_name => "QuotationRequest", :foreign_key => :parent_id
  has_many :direct_similars, :class_name => "QuotationRequest", :foreign_key => :similar_id
  
  has_one :quotation
  has_one :quotation_document, :through => :quotation
  
  validate :validates_length_of_existing_and_free_quotation_request_supplies
  
  validates_presence_of :creator_id, :supplier_id
  validates_presence_of :employee_id, :reference, :supplier_contact_id, :if => :confirmed? # OPTIMIZE : would be better if supplier_contact_id was verified directly when calling has_contact
  validates_presence_of :supplier_contact, :if => :supplier_contact_id # OPTIMIZE : would be better if was done directly when calling has_contact
  validates_presence_of :cancellation_comment, :canceller_id, :if => :cancelled?
  validates_presence_of :creator, :if => :creator_id
  validates_presence_of :supplier, :if => :supplier_id
  validates_presence_of :employee, :if => :employee_id
  validates_presence_of :canceller, :if => :canceller_id
  
  with_options :if => :similar_id do |qr|
    qr.validate :validates_similarity_with_similar
    qr.validate :validates_different_supplier_between_similars
  end
  
  validate :validates_has_not_both_parent_id_and_similar_id
  validate :validates_similarity_of_supplier_between_parents, :if => :parent_id

  with_options :if => Proc.new{ |i| i.new_record? and !i.have_similars?} do |qr|
    qr.validates_inclusion_of :status, :in => [ nil ], :allow_nil => :true
  end
  
  with_options :if => Proc.new{ |i| i.new_record? and i.have_similars?} do |qr|
    qr.before_validation :set_to_confirmed
    qr.validates_inclusion_of :status, :in => [ STATUS_CONFIRMED ]
  end
  
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED, STATUS_REVOKED ], :allow_nil => :true, :if => :was_drafted?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_REVOKED ], :allow_nil => :true, :if => :was_confirmed?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED ], :if => :was_terminated?
  validates_inclusion_of :status, :in => [ STATUS_CONFIRMED ], :allow_nil => :true, :if => :was_cancelled?
  
  validates_associated :quotation_request_supplies
  
  named_scope :pending, :conditions => ["status IS NULL OR status = ?", STATUS_CONFIRMED ],
                        :order => "created_at DESC"
  
  named_scope :terminated, {
    :joins => 'INNER JOIN quotation ON quotation.quotation_request_id == #{id}',
    :conditions => ['quotation.status = ? or quotation.status = ?', Quotation::STATUS_SIGNED, Quotation::STATUS_SENT]
  }
  
  named_scope :cancelled, :conditions => ["status = ?", STATUS_CANCELLED ],
                          :order => "cancelled_at DESC"
  
  attr_accessor :prs_ids
  
  before_validation :build_quotation_request_purchase_request_supplies
  
  after_save :save_quotation_request_supplies, :save_quotation_request_purchase_request_supplies, :destroy_quotation_request_purchase_request_supplies_deselected, :revoke_quotation
  after_save :confirm, :if => :similar_id_and_new_record?
  
  before_destroy :can_be_destroyed?
  
  def validates_length_of_existing_and_free_quotation_request_supplies
    errors.add(:quotation_request_supplies, message_error_for_length_of_existing_and_free_quotation_request_supplies) if existing_and_free_quotation_request_supplies.reject(&:should_destroy?).empty?
  end
  
  def similar_id_and_new_record?
    similar_id and new_record?
  end
  
  #TODO test this method
  def validates_has_not_both_parent_id_and_similar_id
    errors.add(:base, message_error_for_has_not_both_parent_id_and_similar_id) if parent_id and similar_id
  end
  
  def validates_similarity_of_supplier_between_parents
    errors.add(:supplier_id, message_error_for_similarity_of_supplier_between_parents) unless parent.supplier_id == supplier_id
  end
  
  #TODO retest this method
  def validates_similarity_with_similar
    similar_qrs = similar.existing_and_free_quotation_request_supplies
    error_message = message_error_for_similarity_with_similar
    unless similar_qrs.size == existing_and_free_quotation_request_supplies.size
      errors.add(:quotation_request_supplies, error_message)
      return
    end
  
    similar_qrs.reject! do |qrs|
      quotation_request_supplies.detect do |x|
        if x.supply_id and qrs.supply_id
          (x.supply_id == qrs.supply_id) and (x.quantity == qrs.quantity)
        else
          (x.designation == qrs.designation) and (x.quantity == qrs.quantity)
        end
      end
    end
    errors.add(:quotation_request_supplies, error_message) unless similar_qrs.empty?
    
    #TODO add a verification for purchase_request_supplies associated
  end
  
  def validates_different_supplier_between_similars
    errors.add(:supplier_id, message_error_for_different_supplier_between_similars) if similars.detect{ |s| supplier_id == s.supplier_id }
  end
  
  def validates_no_similar_id_if_similar
    (similar_id ? false : true) if (parent_id or root)
    true
  end
  
  def have_similars?
    similars.any?
  end
  
  def terminated_on
    quotation.signed_on if quotation
  end
  
  def drafted?
    !new_record? and status.nil?
  end
  
  def confirmed?
    status == STATUS_CONFIRMED and !terminated?
  end
  
  def terminated?
    quotation ? (quotation.signed? || quotation.sent?) : false
  end
  
  #TODO test this method when all quotation_request_supplies are cancelled
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def revoked?
    status == STATUS_REVOKED
  end
  
  def was_cancelled_and_not_ordered_linked?
    was_cancelled? and !purchase_order
  end
  
  def was_drafted?
    !new_record? and status_was.nil?
  end
  
  def was_confirmed?
    status_was == STATUS_CONFIRMED and !was_terminated?
  end
  
  def was_terminated?
    quotation ? ((quotation.was_signed? || quotation.was_sent?) && status_was == STATUS_CONFIRMED) : false
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def was_revoked?
    status_was == STATUS_REVOKED
  end
  
  def can_be_confirmed?
    (was_drafted? or was_cancelled?) and !has_a_terminated_quotation_request_related?
  end
  
  def can_be_edited?
    was_drafted?
  end
  
  def can_be_sent_to_another_supplier?
    was_confirmed?
  end
  
  def can_be_cancelled?
    was_confirmed? or (was_terminated? and quotation.purchase_order.nil?)
  end
  
  def can_be_destroyed?
    was_drafted?
  end
  
  def can_be_reviewed?
    was_confirmed? or (was_revoked? and !related_quotation_requests.detect{ |qr| qr.was_terminated?})
  end
  
  def can_be_revoked?
    was_drafted? or was_confirmed?
  end
  
  def confirm
    if can_be_confirmed?
      if was_cancelled?
        self.cancellation_comment = nil
        self.canceller_id = nil
        if quotation
          self.quotation.cancellation_comment = nil
          self.canceller_id = nil
          self.quotation.status = nil
        end
      end
      update_reference unless reference
      self.confirmed_at = Time.now
      self.status = STATUS_CONFIRMED
      return self.save
    end
    false
  end
  
  def cancel
    quotation.cancel if quotation and was_terminated?
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED
      return self.save
    end
    false
  end
  
  def quotation?
    !self.quotation.nil?
  end
  
  def revoke_quotation
    if quotation and !quotation.was_cancelled? and !quotation.was_revoked? and was_cancelled?
      quotation.revoke
    end
  end
  
  # TODO enhance the revoke method to make revokation use a revoked_by_id which would contain the "revokator" quotation_request.id and so it will enable to reactivate all revoked quotation_request related with this is if we cancel the terminated quotation_request
  def revoke
    if can_be_revoked?
      self.revoked_at = Time.now
      self.status = STATUS_REVOKED
      return self.save
    end
    false
  end
  
  def similars
    similar ? (([similar] + similar.direct_similars).reject{|s| s == self}) : direct_similars
  end
  
  def supplier_contacts
    supplier ? supplier.contacts : []
  end
  
  def root #return the root "quotation_request" handling the system of parents and similars
    quotation_request = self
    quotation_request = quotation_request.parent || quotation_request.similar while quotation_request.parent || quotation_request.similar
    quotation_request
  end
  
  def children_and_similars
    list = [self]
    list << children.collect{|c| c.children_and_similars} if children.any?
    if similar_id.nil? and similars.any?
      similars.each do |s|
        list << s
        s.children.collect{|c| list << c.children_and_similars} if s.children.any?
      end
    end
    return list.flatten.uniq
  end
  
  #TODO test this method
  def existing_and_free_quotation_request_supplies
    quotation_request_supplies.collect{ |qrs| qrs if !qrs.comment_line }.compact || []
  end
  
  #TODO test this method
  def existing_quotation_request_supplies
    quotation_request_supplies.collect{ |qrs| qrs if !qrs.comment_line and supply_id }.compact || []
  end
  
  #TODO test this method
  def free_quotation_request_supplies
    quotation_request_supplies.collect{ |qrs| qrs if !qrs.comment_line and supply_id.nil? }.compact || []
  end
  
  #TODO test this method
  def comment_line_quotation_request_supplies
    quotation_request_supplies.reject{ |qrs| qrs if qrs.existing_and_free_quotation_request_supplies }.compact || []
  end
  
  def related_quotation_requests
    ([root] + root.children_and_similars).reject{|s| s == self}
  end
  
  def has_a_terminated_quotation_request_related?
    related_terminated_quotation_request ? true : false
  end
  
  #TODO test this method
  def related_terminated_quotation_request
    related_quotation_requests.detect{|rqr| rqr.terminated?}
  end
  
  def set_to_confirmed
    update_reference
    self.confirmed_at = Time.now
    self.status = STATUS_CONFIRMED
  end
  
  #TODO test this method
  def existing_quotation_request_supply_attributes=(existing_qrs_attributes)
    existing_qrs_attributes.each do |attributes|
      if attributes[:id].blank?
        quotation_request_supplies.build( :supply_id => attributes[:supply_id],
                                          :quantity => attributes[:quantity],
                                          :position => attributes[:position],
                                          :supplier_reference => attributes[:supplier_reference],
                                          :supplier_designation => attributes[:supplier_designation],
                                          :purchase_request_supplies_ids => attributes[:purchase_request_supplies_ids],
                                          :purchase_request_supplies_deselected_ids => attributes[:purchase_request_supplies_deselected_ids],
                                          :should_destroy => attributes[:should_destroy])
      else
        qrs = quotation_request_supplies.detect{|qrs| qrs.id == attributes[:id].to_i}
        qrs.quantity = attributes[:quantity]
        qrs.position = attributes[:position]
        qrs.supplier_reference = attributes[:supplier_reference]
        qrs.supplier_designation = attributes[:supplier_designation]
        qrs.purchase_request_supplies_ids = attributes[:purchase_request_supplies_ids]
        qrs.purchase_request_supplies_deselected_ids = attributes[:purchase_request_supplies_deselected_ids]
        qrs.should_destroy = attributes[:should_destroy]
      end
    end
  end
  
  #TODO test this method
  def free_quotation_request_supply_attributes=(free_qrs_attributes)
    free_qrs_attributes.each do |attributes|
      if attributes[:id].blank?
        quotation_request_supplies.build( :quantity => attributes[:quantity],
                                          :position => attributes[:position],
                                          :designation => (attributes[:designation]),
                                          :supplier_reference => attributes[:supplier_reference],
                                          :supplier_designation => attributes[:supplier_designation],
                                          :should_destroy => attributes[:should_destroy])
      else
        qrs = quotation_request_supplies.detect {|t| t.id == attributes[:id].to_i}
        qrs.quantity = attributes[:quantity]
        qrs.position = attributes[:position]
        qrs.designation = qrs.purchase_request_supplies.empty? ? (attributes[:designation]) : nil
        qrs.supplier_reference = attributes[:supplier_reference]
        qrs.supplier_designation = attributes[:supplier_designation]
        qrs.should_destroy = attributes[:should_destroy]
      end
    end
  end
  
  #TODO test this method
  def comment_line_quotation_request_supply_attributes=(comment_line_attributes)
    comment_line_attributes.each do |attributes|
      if attributes[:id].blank?
        quotation_request_supplies.build( :description => attributes[:description],
                                          :comment_line => true,
                                          :position => attributes[:position],
                                          :should_destroy => attributes[:should_destroy])
      else
        qrs = quotation_request_supplies.detect{|t| t.id == attributes[:id].to_i}
        qrs.description = attributes[:description]
        qrs.position = attributes[:position]
        qrs.should_destroy = attributes[:should_destroy]
      end
    end
  end
  
  def save_quotation_request_supplies
    quotation_request_supplies.each{ |qrs| qrs.should_destroy? ? qrs.destroy : qrs.save(false) }
  end
  
  def quotation_document_attributes=(quotation_document_attributes)
    self.quotation_document = PurchaseDocument.new(quotation_document_attributes.first)
  end
  
  def build_copy
    copy = QuotationRequest.new(:supplier_id => supplier_id,
                                :title => title,
                                :supplier_contact_id => supplier_contact_id)
    quotation_request_supplies.each{ |qrs| copy.quotation_request_supplies.build( :supply_id => qrs.supply_id,
                                                                                  :quantity => qrs.quantity,
                                                                                  :position => qrs.position,
                                                                                  :description => qrs.description,
                                                                                  :comment_line => qrs.comment_line,
                                                                                  :designation => qrs.designation) }
    copy
  end
  
  def build_prefilled_similar
    copy = QuotationRequest.new(:similar_id => similar_id || id,
                                :title => title)
    quotation_request_supplies.each{ |qrs|
      copy.quotation_request_supplies.build(:supply_id => qrs.supply_id,
                                            :quantity => qrs.quantity,
                                            :position => qrs.position,
                                            :description => qrs.description,
                                            :comment_line => qrs.comment_line,
                                            :designation => qrs.designation
      )
    }
    copy
  end
  
  def build_prefilled_child
    if can_be_reviewed?
      copy = QuotationRequest.new(:parent_id => id,
                                  :supplier_id => supplier_id,
                                  :title => title,
                                  :supplier_contact_id => supplier_contact_id)
      quotation_request_supplies.each{ |qrs|
        copy.quotation_request_supplies.build(:supply_id => qrs.supply_id,
                                              :quantity => qrs.quantity,
                                              :position => qrs.position,
                                              :description => qrs.description,
                                              :comment_line => qrs.comment_line,
                                              :designation => qrs.designation
        )
      }
      copy
    end
  end
  
  def build_prefilled_quotation
    quotation = build_quotation(:title => title)
    quotation.supplier_id = supplier_id
    real_supplies = quotation_request_supplies.reject{ |qrs| qrs.comment_line? }
    real_supplies.each{ |s|
      quotation.quotation_supplies.build( :supply_id => s.supply_id,
                                          :quantity => s.quantity,
                                          :position => s.position
      )
    }
    quotation
  end
  
  def build_quotation_request_purchase_request_supplies
    quotation_request_supplies.each do |e|
      next unless e.purchase_request_supplies_ids
      e.purchase_request_supplies_ids.split(';').map(&:to_i).each do |s|
        if s > 0 and purchase_request_supply = PurchaseRequestSupply.find_by_id(s)
          e.quotation_request_purchase_request_supplies.build(:purchase_request_supply_id => purchase_request_supply.id) unless e.quotation_request_purchase_request_supplies.detect{|t| t.purchase_request_supply_id == s.to_i}
        end
      end
    end
  end
  
  #TODO test this method
  def build_qrs_from_prs(purchase_request_supplies)
    purchase_request_supplies.collect do |purchase_request_supply|
      if purchase_request_supply.supply_id
        supply = Supply.find(purchase_request_supply.supply_id)
        supplier_supply = SupplierSupply.find_by_supply_id_and_supplier_id(purchase_request_supply.supply_id, self.supplier_id)
        self.existing_quotation_request_supply_attributes=([{ :supply_id            => purchase_request_supply.supply_id, 
                                                              :quantity             => purchase_request_supply.expected_quantity,
                                                              :designation          => supply.designation,
                                                              :supplier_reference   => supplier_supply.supplier_reference,
                                                              :supplier_designation => supplier_supply.supplier_designation }])
        quotation_request_supply = quotation_request_supplies.last
      else
        self.free_quotation_request_supply_attributes=([{:quantity => purchase_request_supply.expected_quantity }])
        quotation_request_supply = quotation_request_supplies.last
      end
      quotation_request_supply.unconfirmed_purchase_request_supplies.each do |e|
        quotation_request_supply.quotation_request_purchase_request_supplies.build(:purchase_request_supply_id => e.id)
      end
    end
  end
  
  def save_quotation_request_purchase_request_supplies
    quotation_request_supplies.each{ |qrs| qrs.quotation_request_purchase_request_supplies.each{ |s| s.save(false) } }
  end
  
  def destroy_quotation_request_purchase_request_supplies_deselected
    self.quotation_request_supplies.each do |e|
      if e.purchase_request_supplies_deselected_ids
        e.purchase_request_supplies_deselected_ids.split(';').each do |s|
          if (s != '' && purchase_request_supply = PurchaseRequestSupply.find(s))
            quotation_request_purchase_request_supply = e.quotation_request_purchase_request_supplies.detect{|t| t.purchase_request_supply_id == s.to_i}
            quotation_request_purchase_request_supply.destroy if quotation_request_purchase_request_supply
          end
        end
      end
    end
  end
  
  def revoke_related_quotation_requests_and_quotations
    related_quotation_requests.each do |r| 
      r.revoke if r.can_be_revoked?
      r.quotation.revoke if r.quotation and r.quotation.can_be_revoked?
    end
  end
  
  def message_error_for_length_of_existing_and_free_quotation_request_supplies
    message_for_validates("quotation_request_supplies", "length_of_existing_and_free_quotation_request_supplies")
  end
  
  def message_error_for_has_not_both_parent_id_and_similar_id
    message_for_validates("base", "not_both_parent_id_and_similar_id")
  end
  
  def message_error_for_similarity_of_supplier_between_parents
    message_for_validates("supplier_id", "similarity_of_supplier_between_parents")
  end
  
  def message_error_for_similarity_with_similar
    message_for_validates("quotation_request_supplies", "similarity_with_similar")
  end
  
  def message_error_for_different_supplier_between_similars
    message_for_validates("supplier_id", "different_supplier_between_similars")
  end
  
  private
    def message_for_validates(attribute, error_type, restriction = "")
      I18n.t("activerecord.errors.models.#{self.class.name.tableize.singularize}.attributes.#{attribute}.#{error_type}", :restriction => restriction)
    end
end
