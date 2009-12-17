class PressProof < ActiveRecord::Base
  ## Plugins
  #acts_as_file
  
  STATUS_CANCELLED = 'cancelled'
  STATUS_CONFIRMED = 'confirmed'
  STATUS_SENDED    = 'sended'
  STATUS_SIGNED    = 'signed'
  STATUS_REVOKED   = 'revoked'
  
  cattr_accessor :form_labels
  
  @@form_labels = {}
  @@form_labels[:internal_actor] = "Contact Graphique :"
  @@form_labels[:creator]        = "Créateur :"
  @@form_labels[:product]        = "Produit :"
  @@form_labels[:unit_measure]   = "Unité de mesures :"
  
  named_scope :actives , :conditions => ["status NOT IN (?)", [STATUS_CANCELLED, STATUS_REVOKED]]
  
  attr_protected :status, :cancelled_on, :confimed_on, :sended_on, :signed_on, :revoked_on, :revoked_by, :revoked_comment, :reference
  
    
  has_attached_file :signed_press_proof, 
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url  => "/press_proofs/:press_proof_id/signed_press_proof"
  
  has_many :press_proof_items
#  has_many :graphic_item_versions, :through => :press_proof_items
#  has_many :mockups, :through => :graphic_item_versions
  
  belongs_to :order
  belongs_to :product
  belongs_to :unit_measure
  belongs_to :document_sending_method
  belongs_to :internal_actor, :class_name => 'Employee'
  belongs_to :creator,        :class_name => 'User'
  belongs_to :revoked_by,     :class_name => 'Employee'
  
  validates_presence_of :internal_actor_id, :creator_id, :order_id, :unit_measure_id, :product_id
  validates_presence_of :order,          :if => :order_id
  validates_presence_of :unit_measure,   :if => :unit_measure_id
  validates_presence_of :creator,        :if => :creator_id
  validates_presence_of :internal_actor, :if => :internal_actor_id
  validates_presence_of :product,        :if => :product_id
#  validates_presence_of :mockups
  
  validates_persistence_of :order_id, :unit_measure_id, :product_id, :unless => :new_record?
  validates_persistence_of :internal_actor_id, :creator_id,          :unless => :can_be_edited?
  
  with_options :if => Proc.new {|n| n.was_cancelled? or n.was_revoked? } do |v|
    v.validates_persistence_of :order_id, :unit_measure_id, :product_id, :internal_actor_id, :creator_id, :cancelled_on,
                               :confirmed_on, :sended_on, :signed_on, :revoked_on, :revoked_by_id, :revoked_comment, :status
  end
  
  # Validations for status according to the procedure
  validates_inclusion_of :status, :in => [nil],                                :if => :new_record?
  validates_inclusion_of :status, :in => [STATUS_CONFIRMED],                   :if => :can_be_confirmed? and :can_be_destroyed?
  validates_inclusion_of :status, :in => [STATUS_SENDED, STATUS_CANCELLED],    :if => :can_be_sended? and :can_be_cancelled?
  validates_inclusion_of :status, :in => [STATUS_SIGNED, STATUS_CANCELLED],    :if => :can_be_signed? and :can_be_cancelled?
  validates_inclusion_of :status, :in => [STATUS_REVOKED],                     :if => :can_be_revoked?
  
  # Validations for confirm
  validates_presence_of  :confirmed_on, :reference, :if => :confirmed?
  
  # Validations for send
  with_options :if => :sended? do |v|
    v.validates_presence_of :sended_on, :document_sending_method_id
    v.validates_presence_of :document_sending_method, :if => :document_sending_method_id
  end
  
  # Validations for sign
  with_options :if => :signed? do |v|
    v.validates_presence_of :signed_on
    v.validate :validates_presence_of_signed_press_proof
#    v.validates_attachment_content_type :signed_press_proof, :content_type => [ 'application/pdf' ]
#    v.validates_attachment_size         :signed_press_proof, :less_than    => 2.megabytes
  end
  
  # Validations for cancel
  validates_presence_of :cancelled_on, :if => :cancelled?
  
  # Validations for revoke
  validates_presence_of :revoked_on, :revoked_by_id, :revoked_comment, :if => :revoked?
  validates_presence_of :revoked_by, :if => :revoked_by_id
 
  validate :validates_with_a_product_not_already_referenced
  
  
  def generate_reference
    # TODO will concat order.public_number + [pattern] + unique_number
    self.id.to_s
  end
  
  def can_be_cancelled?
    return false if self.new_record?
    was_confirmed? or was_sended?
  end
  
  def can_be_confirmed?
    return false if self.new_record?
    status_was.nil?
  end
  
  def can_be_sended?
    was_confirmed?
  end
  
  def can_be_signed?
    was_sended?
  end
  
  def can_be_revoked?
    was_signed?
  end
  
  def can_be_edited?
    confirmed_on.nil?
  end
  
  def can_be_destroyed?
    confirmed_on.nil?
  end
  
  
  def cancel
    return false unless can_be_cancelled?
    self.cancelled_on = Date.today
    self.status       = STATUS_CANCELLED
    self.save
  end
  
  def confirm
    return false unless can_be_confirmed?
    self.confirmed_on = Date.today
    self.reference    = generate_reference
    self.status       = STATUS_CONFIRMED
    self.save
  end
  
  def send_to_customer(options)
    return false unless can_be_sended?
    self.sended_on                  = options[:sended_on]
    self.document_sending_method_id = options[:document_sending_method_id]
    self.status                     = STATUS_SENDED
    self.save
  end
  
  def sign(options)
    return false unless can_be_signed?
    self.signed_on          = options[:signed_on]
    self.signed_press_proof = options[:signed_press_proof] 
    self.status             = STATUS_SIGNED
    self.save
  end
  
  def revoke(options)
    return false unless can_be_revoked?
    self.revoked_on      = options[:revoked_on]
    self.revoked_by_id   = options[:revoked_by_id]
    self.revoked_comment = options[:revoked_comment]
    self.status          = STATUS_REVOKED
    self.save
  end
  
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def confirmed?
    status == STATUS_CONFIRMED
  end
  
  def sended?
    status == STATUS_SENDED
  end
  
  def signed?
    status == STATUS_SIGNED
  end
  
  def revoked?
    status == STATUS_REVOKED
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def was_confirmed?
    status_was == STATUS_CONFIRMED
  end
  
  def was_sended?
    status_was == STATUS_SENDED
  end
  
  def was_signed?
    status_was == STATUS_SIGNED
  end
  
  def was_revoked?
    status_was == STATUS_REVOKED
  end
  
  private
  
    def validates_with_a_product_not_already_referenced
      errors.add(:product_id, "est invalide") unless PressProof.actives.select {|n| n.product_id == self.product_id and n != self}.empty?
    end
    
    def validates_presence_of_signed_press_proof # the method validates_attachment_presence of paperclip seems to be broken when using conditions
      instance      = signed_press_proof.instance
      field_missing = (instance.signed_press_proof_file_name.blank? or instance.signed_press_proof_file_size.blank? or instance.signed_press_proof_content_type.blank?)
      if signed_press_proof.nil? or field_missing
        errors.add(:signed_press_proof, "est requis")
      end
    end
end    
