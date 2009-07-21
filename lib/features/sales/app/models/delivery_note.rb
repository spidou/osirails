class DeliveryNote < ActiveRecord::Base
  STATUS_VALIDATED    = 'validated'
  STATUS_INVALIDATED  = 'invalidated'
  STATUS_SIGNED       = 'signed'
  
  PUBLIC_NUMBER_PATTERN = "%Y%m" # 1 Jan 2009 => 200901
  
  has_permissions :as_business_object
  has_address     :ship_to_address
  has_contacts    :many => false, :accept_from => :order_contacts
  validates_contact_length :is => 1, :message => "doit contenir exactement %s contact"
  
  belongs_to :creator, :class_name  => 'User', :foreign_key => 'user_id'
  belongs_to :delivery_step
  
  has_many :delivery_notes_quotes_product_references, :dependent => :destroy
  has_many :quotes_product_references,                :through   => :delivery_notes_quotes_product_references
  has_many :interventions
  
#  has_one :pending_intervention,    :class_name => 'Intervention', :conditions => [ "delivered IS NULL" ]
#  has_one :successful_intervention, :class_name => 'Intervention', :conditions => [ "delivered = ?", true ]
  def pending_intervention
    collection = interventions.select{ |i| !i.new_record? and i.delivered.nil? }
    raise "pending_intervention should not return more than 1 result. You need to contact your administrator to solve the problem." if collection.size > 1
    return collection.first
  end
  
  def successful_intervention
    collection = interventions.select{ |i| !i.new_record? and i.delivered? }
    raise "successful_intervention should not return more than 1 result. You need to contact your administrator to solve the problem." if collection.size > 1
    return collection.first
  end
  
  validates_presence_of :delivery_notes_quotes_product_references, :ship_to_address
  validates_presence_of :delivery_step_id, :user_id
  validates_presence_of :delivery_step, :if => :delivery_step_id
  validates_presence_of :creator,       :if => :user_id
  
  validates_inclusion_of :status, :in => [ STATUS_VALIDATED, STATUS_INVALIDATED, STATUS_SIGNED ], :allow_nil => true
  
  validates_associated  :delivery_notes_quotes_product_references, :quotes_product_references, :interventions
  
  before_update :save_delivery_notes_quotes_product_references
  after_save :save_interventions
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url => '/delivery_notes/:delivery_note_id/attachment'
  
  attr_protected :status, :validated_on, :invalidated_on, :signed_on, :public_number
  
  def validate
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
    delivery_step ? delivery_step.order.commercial_step.estimate_step.signed_quote : nil
  end
  
  def delivery_notes_quotes_product_reference_attributes=(delivery_notes_quotes_product_reference_attributes)
    delivery_notes_quotes_product_reference_attributes.each do |attributes|
      if attributes[:id].blank?
        delivery_notes_quotes_product_references.build(attributes)
      else
        delivery_notes_quotes_product_reference = delivery_notes_quotes_product_reference.detect { |x| x.id == attributes[:id].to_i }
        delivery_notes_quotes_product_reference.attributes = attributes
      end
    end
  end
  
  def save_delivery_notes_quotes_product_references
    delivery_notes_quotes_product_references.each do |x|
      x.save(false)
    end
  end
  
  def save_interventions
    interventions.each do |i|
      i.save(false) if i.new_record? or i.changed?
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
  
  def can_be_edited?
    uncomplete?
  end
  
  def can_be_deleted?
    uncomplete?
  end
  
  def can_be_validated?
    uncomplete?
  end
  
  def can_be_invalidated?
    validated? and !signed?
  end
  
  # return true if the delivery_note can be signed
  # * if it's validated
  # * if successful_intervention is currently in change
  #   (successful_intervention => intervention with delivered? = true
  #    if previous value of delivered is false, so we know the record has just changed but not saved yet)
  def can_be_signed?
    return false if successful_intervention.nil?
    original_record = Intervention.find(successful_intervention.id)
    
    validated? and !original_record.delivered?
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
  
  def sign_delivery_note(attributes)
    if can_be_signed?
      self.attributes = attributes
      if attributes[:signed_on] and attributes[:signed_on].kind_of?(Date)
        self.signed_on = attributes[:signed_on]
      else
        self.signed_on = Date.civil( attributes["signed_on(1i)"].to_i,
                                     attributes["signed_on(2i)"].to_i,
                                     attributes["signed_on(3i)"].to_i ) rescue nil
      end
      self.attachment = attributes[:attachment]
      self.status = STATUS_SIGNED
      self.save
    else
      errors.add(:base, "Le Bon de Livraison n'est pas prêt")
      false
    end
  end
  
  def order_contacts
    delivery_step ? delivery_step.order.contacts : []
  end
  
  def discards
    delivery_notes_quotes_product_references.select(&:discard).collect(&:discard)
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
