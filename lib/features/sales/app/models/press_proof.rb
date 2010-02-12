class PressProof < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [:confirm, :cancel, :send_to_customer, :sign, :revoke]
  
  STATUS_CANCELLED = 'cancelled'
  STATUS_CONFIRMED = 'confirmed'
  STATUS_SENDED    = 'sended'
  STATUS_SIGNED    = 'signed'
  STATUS_REVOKED   = 'revoked'
  
  named_scope :actives, :conditions => ["status NOT IN (?)", [STATUS_CANCELLED, STATUS_REVOKED]]
  named_scope :signed_list, :conditions => ["status =?", [STATUS_SIGNED]]
  
  attr_protected :status, :cancelled_on, :confimed_on, :sended_on, :signed_on, :revoked_on, :revoked_by, :revoked_comment, :reference
    
  has_attached_file :signed_press_proof, 
                    :path => ':rails_root/assets/:class/:attachment/:reference.:extension',
                    :url  => "/press_proofs/:press_proof_id/signed_press_proof"
  
  has_many :press_proof_items, :order => "created_at, id", :dependent => :destroy                                                 # TODO later when we will add position field
  has_many :graphic_item_versions, :through => :press_proof_items, :order => "press_proof_items.created_at, press_proof_items.id" # we'll need to these order associations with 'position'
  
  has_many :dunnings, :as => :has_dunning, :order => "created_at DESC"
  
  belongs_to :order
  belongs_to :product
  belongs_to :document_sending_method
  belongs_to :internal_actor, :class_name => 'Employee'
  belongs_to :creator,        :class_name => 'User'
  belongs_to :revoked_by,     :class_name => 'User'
  
  validates_presence_of :internal_actor_id, :creator_id, :order_id, :product_id
  validates_presence_of :order,          :if => :order_id
  validates_presence_of :creator,        :if => :creator_id
  validates_presence_of :internal_actor, :if => :internal_actor_id
  validates_presence_of :product,        :if => :product_id
  
  validates_persistence_of :order_id, :product_id, :unless => :new_record?
  validates_persistence_of :internal_actor_id, :creator_id, :press_proof_items, :unless => :can_be_edited?
  
  with_options :if => Proc.new {|n| n.was_cancelled? or n.was_revoked? } do |v|
    v.validates_persistence_of :order_id, :product_id, :internal_actor_id, :creator_id, :cancelled_on, :press_proof_items,
                               :confirmed_on, :sended_on, :signed_on, :revoked_on, :revoked_by_id, :revoked_comment, :status
  end
  
  # Validations for status according to the procedure
  validates_inclusion_of :status, :in => [nil],                                :if => :new_record?
  validates_inclusion_of :status, :in => [nil, STATUS_CONFIRMED],              :if => :can_be_confirmed? and :can_be_destroyed? # TODO refactor test suite
  validates_inclusion_of :status, :in => [STATUS_SENDED, STATUS_CANCELLED],    :if => :can_be_sended? and :can_be_cancelled?
  validates_inclusion_of :status, :in => [STATUS_SIGNED, STATUS_CANCELLED],    :if => :can_be_signed? and :can_be_cancelled?
  validates_inclusion_of :status, :in => [STATUS_REVOKED],                     :if => :can_be_revoked?
  
  # Validations for confirm
  with_options :if => :confirmed? do |v|
    v.validates_date :confirmed_on, :equal_to => Proc.new { Date.today }
    v.validates_presence_of :reference
  end
  
  # Validations for send
  with_options :if => :sended? do |v|
    v.validates_date :sended_on, :on_or_after => :confirmed_on, :on_or_after_message => "ne doit pas être AVANT la date de validation du Bon à tirer&#160;(%s)",
                                 :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    v.validates_presence_of :document_sending_method_id
    v.validates_presence_of :document_sending_method, :if => :document_sending_method_id
  end
  
  # Validations for sign
  with_options :if => :signed? do |v|
    v.validates_date :signed_on, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date de d'envoi du Bon à tirer&#160;(%s)",
                                 :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    v.validate :validates_presence_of_signed_press_proof, :validates_with_a_product_not_already_referenced
    v.validates_attachment_content_type :signed_press_proof, :content_type => [ 'application/pdf', 'application/x-pdf' ]
#    v.validates_attachment_size         :signed_press_proof, :less_than    => 2.megabytes
  end
  
  # Validations for cancel
  validates_date :cancelled_on, :equal_to => Proc.new { Date.today }, :if => :cancelled?
  
  # Validations for revoke
  with_options :if => :revoked? do |v|
    v.validates_date :revoked_on, :equal_to => Proc.new { Date.today }
    v.validates_presence_of :revoked_on, :revoked_by_id, :revoked_comment
    v.validates_presence_of :revoked_by, :if => :revoked_by_id
  end
 
  validates_associated :press_proof_items
 
  validate :validates_presence_of_press_proof_items_custom # use this because the deletion of a resource is done after validation by using a flag, so we must validate the flag state
  validate :validates_mockups
  
  after_save :save_press_proof_items
    
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:internal_actor]          = "Contact Graphique :"
  @@form_labels[:creator]                 = "Créateur :"
  @@form_labels[:product]                 = "Produit :"
  @@form_labels[:product_description]     = "Description :"
  @@form_labels[:unit_measure]            = "Unité de mesures :"
  @@form_labels[:sended_on]               = "BAT envoyé au client le :"
  @@form_labels[:document_sending_method] = "Par :"
  @@form_labels[:signed_on]               = "BAT signé par le client le :"
  @@form_labels[:signed_press_proof]      = "Fichier (BAT signé) :"
  @@form_labels[:revoked_comment]         = "Motif de l'annulation :"
  @@form_labels[:revoked_by]              = "BAT annulé par :"
  @@form_labels[:revoked_at]              = "BAT annulé le :"
  @@form_labels[:cancelled_at]            = "BAT annulé le :"
  @@form_labels[:created_at]              = "Date de création :"
  @@form_labels[:status]                  = "État actuel :"
  
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
    was_sended? and PressProof.signed_list.select {|n| n.product_id == self.product_id and n != self}.empty?
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
    self.sended_on                  = options[:sended_on] || get_date_from_params(options,'sended_on')
    self.document_sending_method_id = options[:document_sending_method_id]
    self.status                     = STATUS_SENDED
    self.save
  end
  
  def sign(options)
    return false unless can_be_signed?
    self.signed_on          = options[:signed_on] || get_date_from_params(options,'signed_on')
    self.signed_press_proof = options[:signed_press_proof] 
    self.status             = STATUS_SIGNED
    self.save
  end
  
  def revoke(options)
    return false unless can_be_revoked?
    self.revoked_on      = options[:revoked_on] || get_date_from_params(options,'revoked_on')
    self.revoked_by_id   = options[:revoked_by_id]
    self.revoked_comment = options[:revoked_comment]
    self.status          = STATUS_REVOKED
    self.save
  end
  
  def get_date_from_params(params,attribute)
    y = params["#{attribute}(1i)"]
    m = params["#{attribute}(2i)"]
    d = params["#{attribute}(3i)"]
    "#{y}/#{m}/#{d}".to_date
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
  
  def press_proof_item_attributes=(press_proof_item_attributes)
    collection = self.press_proof_items
    press_proof_item_attributes.each do |attributes|
      attributes[:press_proof_id] = self.id
      record                      = collection.detect {|n| n.graphic_item_version_id == attributes[:graphic_item_version_id].to_i}
      
      if record.nil?
        self.press_proof_items.build(attributes)
      else
        record.attributes = attributes
      end
    end
  end
  
  def product_description
    product ? product.description : nil
  end
  
  # Method to get all press_proof's graphic_item including unsaved one
  #
  def get_all_graphic_item_versions
    return graphic_item_versions + get_unsaved_graphic_item_versions
  end
  
  # Method to get all press_proof's selected mockups
  # used to manage "mockups" list
  #
  def get_selected_mockups
    selected_graphic_item_versions = graphic_item_versions.reject do |graphic_item_version|
      press_proof_items.detect {|n| n.graphic_item_version_id == graphic_item_version.id and n.should_destroy? }
    end
    selected_graphic_item_versions += get_unsaved_graphic_item_versions
    
    return selected_graphic_item_versions.collect{|n| n.graphic_item.id}
  end
  
  # Method to get all press_proof's unselected mockups
  # used to manage "press_proof_mockups" list
  #
  def get_unselected_mockups
    unselected_graphic_item_versions = graphic_item_versions.select do |graphic_item_version|
      press_proof_items.detect {|n| n.graphic_item_version_id == graphic_item_version.id and n.should_destroy? }
    end
    
    return unselected_graphic_item_versions.collect{|n| n.graphic_item.id}
  end
  
  # Method to get all graphic_item_versions that are selected but not saved yet
  # Usefull, because we do not save 'graphic_item_version' but the join model 'press_proof_item'
  # so until the press_proof is not successfully saved (passed validations) we cannot retrieve the new graphic_item_versions
  # doing press_proof.graphic_item_versions, then we must pass through press_proof.press_proof_items to retrieve unsaved_graphic_item_versions.
  #
  def get_unsaved_graphic_item_versions
    result = order.mockups.select do |graphic_item|
      press_proof_items.detect {|n| n.graphic_item_version_id == graphic_item.current_version.id and n.id.nil? and !n.should_destroy? }
    end
    
    return result.collect(&:current_version)
  end
  
  private
  
    def save_press_proof_items
      self.press_proof_items.each do |press_proof_item|
        if press_proof_item.should_destroy?    
          press_proof_item.destroy    
        else
          press_proof_item.save(false)
        end
      end 
    end
  
    def validates_with_a_product_not_already_referenced
      unless PressProof.signed_list.select {|n| n.product_id == self.product_id and n != self}.empty?
        errors.add(:product_id, "est invalide, le produit est déjà référencé dans un BAT signé")
      end
    end
    
    def validates_mockups
      collection = self.press_proof_items.collect(&:graphic_item_version_id)
      graphic_item_versions = GraphicItemVersion.all(:conditions => ["id in (?)",collection])
      
      unless graphic_item_versions.select {|n| n.graphic_item.class == GraphicDocument}.empty?
        errors.add(:press_proof_items, "doit contenir uniquement des maquettes")
      end
      
      unless graphic_item_versions.select {|n| n.graphic_item.class == Mockup and n.graphic_item.product.id != self.product.id}.empty?
        errors.add(:press_proof_items, "doit contenir uniquement des maquettes concernant le produit du BAT")
      end
    end
    
    def validates_presence_of_signed_press_proof # the method validates_attachment_presence of paperclip seems to be broken when using conditions
      instance      = signed_press_proof.instance
      field_missing = (instance.signed_press_proof_file_name.blank? or instance.signed_press_proof_file_size.blank? or instance.signed_press_proof_content_type.blank?)
      if signed_press_proof.nil? or field_missing
        errors.add(:signed_press_proof, "est requis")
      end
    end
    
    def validates_presence_of_press_proof_items_custom
      errors.add(:press_proof_items, "est requis") if self.press_proof_items.select {|n| !n.should_destroy?}.empty?
    end
end    
