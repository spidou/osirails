class DeliveryNote < ActiveRecord::Base
  STATUS_VALIDATED    = 'validated'
  STATUS_INVALIDATED  = 'invalidated'
  STATUS_SIGNED       = 'signed'
  
  PUBLIC_NUMBER_PATTERN = "%Y%m" # 1 Jan 2009 => 200901
  
  has_permissions :as_business_object
  has_address     :ship_to_address
  has_contact     :accept_from => :order_contacts
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url  => '/delivery_notes/:delivery_note_id/attachment'
  
  belongs_to :order
  belongs_to :creator, :class_name  => 'User'
  
  has_many :delivery_note_items, :dependent => :destroy
  has_many :quote_items,         :through   => :delivery_note_items
  has_many :interventions
  
  validates_contact_presence
  
  validates_presence_of :delivery_note_items, :ship_to_address
  validates_presence_of :order_id, :creator_id
  validates_presence_of :order,   :if => :order_id
  validates_presence_of :creator, :if => :creator_id
  
  with_options :if => :validated? do |dn|
    dn.validates_presence_of :validated_on
    dn.validates_presence_of :public_number
  end
  
  validates_presence_of :invalidated_on,  :if => :invalidated?
  
  with_options :if => :signed? do |dn|
    dn.validates_presence_of :signed_on
    dn.validates_presence_of :successful_intervention
    dn.validate :validates_presence_of_attachment
  end
  
  validates_persistence_of :creator_id, :order_id
  
  validates_persistence_of :ship_to_address,
                           :contacts,
                           :delivery_note_items, 
                           :validated_on,
                           :public_number, :unless => :was_uncomplete?
  
  validates_persistence_of :invalidated_on, :interventions, :status, :if => :was_invalidated?
  
  validates_persistence_of :signed_on, :attachment, :interventions, :status, :if => :was_signed?
  
  validates_inclusion_of :status, :in => [ STATUS_VALIDATED, STATUS_INVALIDATED, STATUS_SIGNED ], :allow_nil => true
  
  validates_associated  :delivery_note_items, :quote_items, :interventions
  
  validate :validates_interventions
  
  before_update :save_delivery_note_items
  after_save :save_interventions
  
  attr_protected :status, :validated_on, :invalidated_on, :signed_on, :public_number
  
  def validates_presence_of_attachment # the method validates_attachment_presence of paperclip seems to be broken when using conditions
    if attachment.nil? or attachment.instance.attachment_file_name.blank? or attachment.instance.attachment_file_size.blank? or attachment.instance.attachment_content_type.blank?
      errors.add(:attachment, "est requis")
    end
  end
  
  def pending_intervention
    collection = interventions.select{ |i| !i.new_record? and i.delivered.nil? }
    raise "pending_intervention should not return more than 1 result. Please contact your administrator to solve the problem." if collection.size > 1
    return collection.first
  end
  
  def successful_intervention
    collection = interventions.select{ |i| !i.new_record? and i.delivered? }
    raise "successful_intervention should not return more than 1 result. Please contact your administrator to solve the problem." if collection.size > 1
    return collection.first
  end
  
  def validates_interventions
    if has_new_interventions?
      errors.add(:interventions, "est invalide, impossible de créer une nouvelle intervention pour l'instant") if pending_intervention
      errors.add(:interventions, "est invalide, il n'est plus possible de créer d'intervention pour ce Bon de Livraison") if successful_intervention
      errors.add(:interventions, "ne peut être créé à partir d'un Bon de Livraison non validé") unless validated?
    end
  end
  
  def has_new_interventions?
    !interventions.select(&:new_record?).empty?
  end
  
  def associated_quote
    order ? order.signed_quote : nil
  end
  
  def delivery_note_item_attributes=(delivery_note_item_attributes)
    delivery_note_item_attributes.each do |attributes|
      if attributes[:id].blank?
        delivery_note_items.build(attributes)
      else
        delivery_note_item = delivery_note_item.detect { |x| x.id == attributes[:id].to_i }
        delivery_note_item.attributes = attributes
      end
    end
  end
  
  def save_delivery_note_items
    delivery_note_items.each do |x|
      x.save(false)
    end
  end
  
  def save_interventions
    interventions.each do |i|
      i.save(false)# if i.new_record? or i.changed?
    end
  end
  
  # delivery note is considered as 'uncomplete' if its status is nil
  def uncomplete?
    status.nil?
  end
  
  def validated?
    status == STATUS_VALIDATED
  end
  
  def invalidated?
    status == STATUS_INVALIDATED
  end
  
  def signed?
    status == STATUS_SIGNED
  end
  
  def was_uncomplete?
    status_was.nil?
  end
  
  def was_validated?
    status_was === STATUS_VALIDATED
  end
  
  def was_invalidated?
    status_was === STATUS_INVALIDATED
  end
  
  def was_signed?
    status_was === STATUS_SIGNED
  end
  
  def can_be_edited?
    was_uncomplete?
  end
  
  def can_be_deleted?
    was_uncomplete?
  end
  
  def can_be_validated?
    was_uncomplete?
  end
  
  def can_be_invalidated?
    was_validated?# and !signed?
  end
  
  # return true if the delivery_note can be signed
  # * if it's validated
  # * if successful_intervention is currently in change
  #   (successful_intervention => intervention with delivered? = true
  #    if previous value of delivered is false, so we know the record has just changed but not saved yet)
  def can_be_signed?
    #return false if successful_intervention.nil?
    ##original_record = Intervention.find(successful_intervention.id)
    #
    ##validated? and !original_record.delivered?
    #validated? and !successful_intervention.delivered_was
    was_validated?
  end
  
  def validate_delivery_note
    if can_be_validated?
      self.validated_on = Date.today
      self.public_number = generate_public_number
      self.status = STATUS_VALIDATED
      self.save
    else
      errors.add(:base, "Le Bon de Livraison n'est pas prêt")
      false
    end
  end
  
  def invalidate_delivery_note
    if can_be_invalidated?
      self.invalidated_on = Date.today
      self.status = STATUS_INVALIDATED
      self.save
    else
      errors.add(:base, "Le Bon de Livraison n'est pas prêt")
      false
    end
  end
  
  def sign_delivery_note#(attributes)
    if can_be_signed?
      #self.attributes = attributes
      #if attributes[:signed_on] and attributes[:signed_on].kind_of?(Date)
      #  self.signed_on = attributes[:signed_on]
      #else
      #  self.signed_on = Date.civil( attributes["signed_on(1i)"].to_i,
      #                               attributes["signed_on(2i)"].to_i,
      #                               attributes["signed_on(3i)"].to_i ) rescue nil
      #end
      #self.attachment = attributes[:attachment]
      self.status = STATUS_SIGNED
      self.save
    else
      errors.add(:base, "Le Bon de Livraison n'est pas prêt")
      false
    end
  end
  
  def order_contacts
    order ? order.contacts : []
  end
  
  def discards
    delivery_note_items.select(&:discard).collect(&:discard)
  end
  
  def has_discards?
    !discards.empty?
  end
  
  private
    def generate_public_number
      return public_number if !public_number.blank?
      prefix = Date.today.strftime(PUBLIC_NUMBER_PATTERN)
      quantity = DeliveryNote.find(:all, :conditions => [ "public_number LIKE ?", "#{prefix}%" ]).size + 1
      "#{prefix}#{quantity.to_s.rjust(3,'0')}"
    end
end
