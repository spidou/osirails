## DATABASE STRUCTURE
# A integer  "order_id"
# A integer  "creator_id"
# A integer  "delivery_note_type_id"
# A integer  "delivery_note_contact_id"
# A string   "status"
# A string   "reference"
# A string   "attachment_file_name"
# A string   "attachment_content_type"
# A integer  "attachment_file_size"
# A date     "published_on"
# A date     "signed_on"
# A datetime "confirmed_at"
# A datetime "cancelled_at"
# A datetime "created_at"
# A datetime "updated_at"

class DeliveryNote < ActiveRecord::Base
  STATUS_CONFIRMED    = 'confirmed'
  STATUS_CANCELLED    = 'cancelled'
  STATUS_SIGNED       = 'signed'
  
  has_permissions :as_business_object, :additional_class_methods => [ :confirm, :schedule, :realize, :sign, :cancel ]
  has_address     :ship_to_address
  has_contact     :delivery_note_contact, :accept_from => :order_and_customer_contacts, :required => true
  has_reference   :symbols => [:order], :prefix => :sales
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => '/delivery_notes/:delivery_note_id/attachment'
  
  belongs_to :order
  belongs_to :creator, :class_name => 'User'
  belongs_to :delivery_note_type
  
  has_many :delivery_note_items, :dependent => :destroy
  has_many :end_products,        :through   => :delivery_note_items
  
  has_many :delivery_interventions, :order => "created_at DESC"
  has_one  :pending_delivery_intervention,    :class_name => "DeliveryIntervention", :conditions => [ 'delivered IS NULL AND cancelled_at IS NULL and postponed IS NULL' ], :order => "created_at DESC"
  has_one  :delivered_delivery_intervention,  :class_name => "DeliveryIntervention", :conditions => [ 'delivered = ?', true ], :order => "created_at DESC"
  
  has_many :delivery_note_invoices
  has_many :all_invoices, :through => :delivery_note_invoices, :source => :invoice
  has_one  :invoice,      :through => :delivery_note_invoices, :conditions => [ "invoices.status IS NULL OR invoices.status != ?", Invoice::STATUS_CANCELLED ] #TODO test this relationship
  
  named_scope :actives, :conditions => [ 'status IS NULL or status != ?', STATUS_CANCELLED ]
  named_scope :pending, :conditions => [ 'status = ?', STATUS_CONFIRMED ]
  named_scope :signed,  :conditions => [ 'status = ?', STATUS_SIGNED ]
  
  validates_presence_of :ship_to_address
  validates_presence_of :order_id, :creator_id, :delivery_note_type_id
  validates_presence_of :order,               :if => :order_id
  validates_presence_of :creator,             :if => :creator_id
  validates_presence_of :delivery_note_type,  :if => :delivery_note_type_id
  
  validates_presence_of :published_on, :confirmed_at, :reference,  :if => :confirmed?
  validates_presence_of :cancelled_at,                             :if => :cancelled?
  
  with_options :if => :signed? do |dn|
    dn.validates_presence_of :signed_on
    
    dn.validates_date :signed_on, :on_or_before => Date.today,
                                  :on_or_after  => :published_on
    
    dn.validate :validates_presence_of_attachment
  end
  
  validates_inclusion_of :status, :in => [ nil, STATUS_CONFIRMED, STATUS_CANCELLED ], :if => :was_uncomplete?
  validates_inclusion_of :status, :in => [ STATUS_CANCELLED, STATUS_SIGNED ],         :if => :was_confirmed?
  
  validates_persistence_of :creator_id, :order_id
  validates_persistence_of :ship_to_address, :delivery_note_contact_id,
                           :delivery_note_items, :published_on, :confirmed_at,        :if => :confirmed_at_was
  validates_persistence_of :cancelled_at, :delivery_interventions, :status,           :if => :cancelled_at_was
  validates_persistence_of :signed_on, :attachment, :delivery_interventions, :status, :if => :signed_on_was
  
  validates_associated  :delivery_note_items, :end_products, :delivery_interventions
  
  validate :validates_delivery_interventions, :validates_presence_of_delivery_note_items
  
  before_destroy :can_be_destroyed?
  
  after_save :save_delivery_note_items
  
  active_counter :counters  => { :pending_delivery_notes  => :integer,
                                 :pending_total           => :float },
                 :callbacks => { :pending_delivery_notes  => :after_save,
                                 :pending_total           => :after_save }
  
  attr_protected :status, :reference, :confirmed_at, :cancelled_at
  
  def validates_presence_of_attachment # the method validates_attachment_presence of paperclip seems to be broken when using conditions
    if attachment.nil? or attachment.instance.attachment_file_name.blank? or attachment.instance.attachment_file_size.blank? or attachment.instance.attachment_content_type.blank?
      errors.add(:attachment, errors.generate_message(:attachment, :blank))
    end
  end
  
  def validates_delivery_interventions
    if has_new_delivery_interventions?
      errors.add(:delivery_interventions, errors.generate_message(:delivery_interventions, :unconfirmed)) unless confirmed?
      errors.add(:delivery_interventions, errors.generate_message(:delivery_interventions, :pending))     if pending_delivery_intervention
      errors.add(:delivery_interventions, errors.generate_message(:delivery_interventions, :delivered))   if delivered_delivery_intervention
    end
  end
  
  def validates_presence_of_delivery_note_items
    errors.add(:delivery_note_items, errors.generate_message(:delivery_note_items, :blank)) if delivery_note_items.reject(&:should_destroy?).empty?
  end
  
  def has_new_delivery_interventions?
    !delivery_interventions.select(&:new_record?).empty?
  end
  
  # return if the delivery_note is associated to an active invoice (when status != cancelled)
  def billed?
    invoice.is_a?(Array) ? !invoice.empty? : !invoice.nil?
  end
  
  # return if the associated invoice is confirmed (and above)
  def billed_and_confirmed?
    billed? ? !invoice.confirmed_at_was.nil? : false
  end
  
  def signed_quote
    order and order.signed_quote
  end
  
  #TODO test this method
  def ready_to_deliver_end_products_and_quantities
    order ? order.ready_to_deliver_end_products_and_quantities : []
  end
  
  #TODO test this method
  def build_delivery_note_items_from_remaining_quantity_of_end_products_to_deliver
    return unless order and order.signed_quote
    
    order.signed_quote.end_products.each do |end_product|
      next unless end_product.remaining_quantity_to_deliver > 0
      delivery_note_items.build(:order_id        => order.id,
                                :end_product_id  => end_product.id,
                                :quantity        => end_product.remaining_quantity_to_deliver)
    end
  end
  
  #TODO test this method
  def build_missing_delivery_note_items_from_ready_to_deliver_end_products
    ready_to_deliver_end_products_and_quantities.each do |hash| #TODO shouldn't we use 'collect' instead of 'each' ?
      unless item = delivery_note_items.detect{ |i| i.end_product_id == hash[:end_product_id] }
        item = delivery_note_items.build(:order_id        => self.order_id,
                                         :end_product_id  => hash[:end_product_id])
      end
    end
  end
  
  def delivery_note_item_attributes=(delivery_note_item_attributes)
    delivery_note_item_attributes.each do |attributes|
      if attributes[:id].blank?
        delivery_note_items.build(attributes) unless attributes[:quantity].to_i.zero?
      else
        delivery_note_item = delivery_note_items.detect { |x| x.id == attributes[:id].to_i }
        delivery_note_item.attributes = attributes
      end
    end
  end
  
  def save_delivery_note_items
    delivery_note_items.each do |item|
      if item.should_destroy?
        item.destroy
      else
        item.save(false)
      end
    end
  end
  
  def delivery?
    delivery_note_type.delivery?
  end
  
  def installation?
    delivery_note_type.installation?
  end
  
  # delivery note is considered as 'uncomplete' if its status is nil
  def uncomplete?
    status.nil?
  end
  
  def confirmed?
    status == STATUS_CONFIRMED
  end
  
  def cancelled?
    status == STATUS_CANCELLED
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
  
  def was_signed?
    status_was == STATUS_SIGNED
  end
  
  def can_be_added?
    signed_quote and ready_to_deliver_end_products_and_quantities.any? and !order.all_is_delivered_or_scheduled?
  end
  
  def can_be_edited?
    !new_record? and was_uncomplete?
  end
  
  def can_be_downloaded? # with PDF generator
    reference_was
  end
  
  def can_be_destroyed?
    !new_record? and was_uncomplete?
  end
  
  def can_be_confirmed?
    !new_record? and was_uncomplete?
  end
  
  def can_be_cancelled?
    !new_record? and !was_signed? and !was_cancelled? and !delivered_delivery_intervention
  end
  
  def can_be_scheduled?
    !new_record? and !was_signed? and !was_cancelled? and !delivered_delivery_intervention
  end
  
  def can_be_realized?
    was_confirmed? and pending_delivery_intervention
  end
  
  def can_be_signed?
    was_confirmed? and delivered_delivery_intervention
  end
  
  def confirm
    if can_be_confirmed?
      update_reference
      self.published_on ||= Date.today
      self.confirmed_at = Time.now
      self.status = STATUS_CONFIRMED
      self.save
    else
      errors.add(:base, errors.generate_message(:base, :cant_be_confirmed))
      false
    end
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.status = STATUS_CANCELLED
      self.save
    else
      errors.add(:base, errors.generate_message(:base, :cant_be_cancelled))
      false
    end
  end
  
  def sign
    if can_be_signed?
      self.status = STATUS_SIGNED
      self.save
    else
      errors.add(:base, errors.generate_message(:base, :cant_be_signed))
      false
    end
  end
  
  def order_and_customer_contacts
    order ? order.all_contacts_and_customer_contacts : []
  end
  
  def discards
    return [] unless delivered_delivery_intervention
    delivered_delivery_intervention.discards
  end
  
  def has_discards?
    !discards.length.zero?
  end
  
  def total_with_taxes
    delivery_note_items.collect(&:total_with_taxes).compact.sum
  end
  
  def number_of_pieces
    delivery_note_items.collect(&:quantity).compact.sum
  end
  
  def number_of_products
    delivery_note_items.count
  end
  
  def number_of_delivered_pieces
    number_of_pieces - number_of_discarded_pieces
  end
  
  def number_of_discarded_pieces
    discards.collect(&:quantity).sum
  end
  
  def self_and_siblings
    order.delivery_notes.actives
  end
  
  def siblings
    self_and_siblings - [ self ]
  end
  
  def pending_delivery_notes_counter # @override (active_counter)
    DeliveryNote.pending.count
  end
  
  def pending_total_counter # @override (active_counter)
    DeliveryNote.pending.collect(&:total_with_taxes).compact.sum
  end
end
