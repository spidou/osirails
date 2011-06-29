class PressProof < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [:confirm, :cancel, :send_to_customer, :sign, :revoke]
  has_reference   :symbols => [:order], :prefix => :sales
  
  STATUS_CANCELLED = 'cancelled'
  STATUS_CONFIRMED = 'confirmed'
  STATUS_SENDED    = 'sended'
  STATUS_SIGNED    = 'signed'
  STATUS_REVOKED   = 'revoked'
  
  named_scope :actives, :conditions => ["status NOT IN (?)", [STATUS_CANCELLED, STATUS_REVOKED]]
  named_scope :pending, :conditions => [ 'status IN (?)', [STATUS_CONFIRMED, STATUS_SENDED] ]
  named_scope :signed,  :conditions => [ 'status = ?', STATUS_SIGNED ]
    
  has_attached_file :signed_press_proof, 
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => "/press_proofs/:press_proof_id/signed_press_proof"
  
  has_many :press_proof_items, :order => "position", :dependent => :destroy
  has_many :graphic_item_versions, :through => :press_proof_items, :order => "press_proof_items.position"
  
  has_many :dunnings, :as => :has_dunning, :order => "created_at DESC"
  
  belongs_to :order
  belongs_to :end_product
  belongs_to :document_sending_method
  belongs_to :internal_actor, :class_name => 'Employee'
  belongs_to :creator,        :class_name => 'User'
  belongs_to :revoked_by,     :class_name => 'User'
  
  validates_presence_of :internal_actor_id, :creator_id, :order_id, :end_product_id
  validates_presence_of :order,          :if => :order_id
  validates_presence_of :creator,        :if => :creator_id
  validates_presence_of :internal_actor, :if => :internal_actor_id
  validates_presence_of :end_product,    :if => :end_product_id
  
  validates_persistence_of :order_id, :end_product_id,                                          :if => :created_at_was
  validates_persistence_of :internal_actor_id, :creator_id, :press_proof_items, :confirmed_on,  :if => :confirmed_on_was
  validates_persistence_of :sended_on,                                                          :if => :sended_on_was
  validates_persistence_of :signed_on,                                                          :if => :signed_on_was
  validates_persistence_of :revoked_on, :revoked_by_id, :revoked_comment,                       :if => :revoked_on_was
  validates_persistence_of :cancelled_on,                                                       :if => :cancelled_on_was
  
  validates_persistence_of :status, :if => Proc.new { |p| p.was_cancelled? or p.was_revoked? }
  
  # Validations for status according to the procedure
  validates_inclusion_of :status, :in => [nil],                                     :if => :new_record?
  validates_inclusion_of :status, :in => [nil, STATUS_CONFIRMED, STATUS_CANCELLED], :if => :was_uncomplete?
  validates_inclusion_of :status, :in => [STATUS_SENDED, STATUS_CANCELLED],         :if => :was_confirmed?
  validates_inclusion_of :status, :in => [STATUS_SIGNED, STATUS_CANCELLED],         :if => :was_sended?
  validates_inclusion_of :status, :in => [STATUS_REVOKED],                          :if => :was_signed?
  
  
  # Validations for confirm
  with_options :if => :confirmed? do |v|
    v.validates_date :confirmed_on, :equal_to => Date.today
    v.validates_presence_of :reference
  end
  
  # Validations for send
  with_options :if => :sended? do |v|
    v.validates_date :sended_on, :on_or_after   => :confirmed_on,
                                 :on_or_before  => Date.today
    v.validates_presence_of :document_sending_method_id
    v.validates_presence_of :document_sending_method, :if => :document_sending_method_id
  end
  
  # Validations for sign
  with_options :if => :signed? do |v|
    v.validates_date :signed_on, :on_or_after   => :sended_on,
                                 :on_or_before  => Date.today
    v.validate :validates_presence_of_signed_press_proof, :validates_with_a_end_product_not_already_referenced
    v.validates_attachment_content_type :signed_press_proof, :content_type => [ 'application/pdf', 'application/x-pdf' ]
#    v.validates_attachment_size         :signed_press_proof, :less_than    => 2.megabytes
  end
  
  # Validations for cancel
  validates_date :cancelled_on, :equal_to => Date.today, :if => :cancelled?
  
  # Validations for revoke
  with_options :if => :revoked? do |v|
    v.validates_date :revoked_on, :equal_to => Date.today
    v.validates_presence_of :revoked_on, :revoked_by_id, :revoked_comment
    v.validates_presence_of :revoked_by, :if => :revoked_by_id
  end
 
  validates_associated :press_proof_items
 
  validate :validates_presence_of_press_proof_items_custom # use this because the deletion of a resource is done after validation by using a flag, so we must validate the flag state
  validate :validates_mockups
  
  # Callbacks
  after_save :save_press_proof_items
  before_create :can_be_created?
  before_destroy :can_be_destroyed?
  
  active_counter :counters  => { :pending_press_proofs => :integer },
                 :callbacks => { :pending_press_proofs => :after_save }
  
  attr_protected :status, :cancelled_on, :confirmed_on
    
  def sorted_press_proof_items
    press_proof_items.sort_by(&:position)
  end
  
   # OPTIMIZE this is a copy of an already existant method in quote.rb 
  def signed_quote
    order and order.signed_quote
  end
  
  def can_be_downloaded? # with PDF generator
    reference_was
  end
  
  def can_be_cancelled?
    !new_record? and ( was_confirmed? or was_sended? )
  end
  
  def can_be_confirmed?
    !new_record? and was_uncomplete? and end_product_without_signed_press_proof?
  end
  
  def can_be_sended?
    was_confirmed? and end_product_without_signed_press_proof?
  end
  
  def can_be_signed?
    was_sended? and end_product_without_signed_press_proof?
  end
  
  def can_be_revoked?
    was_signed?
  end
  
  def can_be_edited?
    !new_record? and was_uncomplete? and end_product_without_signed_press_proof?
  end
  
  def can_be_destroyed?
    !new_record? and was_uncomplete?
  end
  
  def can_be_created?
    end_product_without_signed_press_proof?
  end
  
  def end_product_without_signed_press_proof?
    !end_product.has_signed_press_proof?
  end
  
  def cancel
    return false unless can_be_cancelled?
    self.cancelled_on = Date.today
    self.status       = STATUS_CANCELLED
    self.save
  end
  
  def confirm
    return false unless can_be_confirmed?
    update_reference
    self.confirmed_on = Date.today
    self.status       = STATUS_CONFIRMED
    self.save
  end
  
  def send_to_customer(attributes)
    return false unless can_be_sended?
    self.attributes = attributes
    self.status     = STATUS_SENDED
    self.save
  end
  
  def sign(attributes)
    return false unless can_be_signed?
    self.attributes = attributes
    self.status     = STATUS_SIGNED
    self.save
  end
  
  def revoke(attributes)
    return false unless can_be_revoked?
    self.attributes = attributes
    self.revoked_on = Date.today
    self.status     = STATUS_REVOKED
    self.save
  end
  
  def uncomplete?
    status.nil?
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
  
  def was_uncomplete?
    status_was.nil?
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
      attributes = attributes.merge(:press_proof_id => self.id)
      record = collection.detect {|n| n.graphic_item_version_id == attributes[:graphic_item_version_id].to_i}
      
      if record.nil?
        self.press_proof_items.build(attributes)
      else
        record.attributes = attributes
      end
    end
  end
  
  def end_product_description
    end_product ? end_product.description : nil
  end
  
  # Method to get all press_proof's graphic_item including unsaved one
  #
  def all_graphic_item_versions
    graphic_item_versions + unsaved_graphic_item_versions
  end
  
  # Method to get all press_proof's selected mockups
  # used to manage "mockups" list
  #
  def selected_mockups
    ##OPTIMIZE with a code like the following
    #all_graphic_item_versions - unselected_mockups
    
    selected_graphic_item_versions = graphic_item_versions.reject do |graphic_item_version|
      press_proof_items.detect {|n| n.graphic_item_version_id == graphic_item_version.id and n.should_destroy? }
    end
    selected_graphic_item_versions += unsaved_graphic_item_versions
    
    return selected_graphic_item_versions.collect{|n| n.graphic_item.id}
  end
  
  # Method to get all press_proof's unselected mockups
  # used to manage "press_proof_mockups" list
  #
  def unselected_mockups
    ##OPTIMIZE with a code like the following
    #to_destroy_press_proof_items = press_proof_items.select(&:should_destroy?)
    #graphic_item_versions.select{ |graphic_item_version| to_destroy_press_proof_items.detect{ |i| i.graphic_item_version_id == graphic_item_version.id } }
    
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
  def unsaved_graphic_item_versions
    ##OPTIMIZE with a code like the following
    #unsaved_press_proof_items = press_proof_items.select(&:new_record?).reject(&:should_destroy?)
    #order.mockups.select{ |m| unsaved_press_proof_items.detect{ |i| i.graphic_item_version_id == m.current_version.id } }.collect(&:current_version)
    
    result = order.mockups.select do |graphic_item|
      press_proof_items.detect {|n| n.graphic_item_version_id == graphic_item.current_version.id and n.id.nil? and !n.should_destroy? }
    end
    
    return result.collect(&:current_version)
  end
  
  def pending_press_proofs_counter # @override (active_counter)
    PressProof.pending.count
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
  
    def validates_with_a_end_product_not_already_referenced
      unless end_product_without_signed_press_proof?
        errors.add(:end_product_id, "est invalide, le produit est déjà référencé dans un BAT signé")
      end
    end
    
    def validates_mockups
      collection = self.press_proof_items.collect(&:graphic_item_version_id)
      graphic_item_versions = GraphicItemVersion.all(:conditions => ["id in (?)",collection])
      
      unless graphic_item_versions.select {|n| n.graphic_item.class == GraphicDocument}.empty?
        errors.add(:press_proof_items, "doit contenir uniquement des maquettes")
      end
      
      unless graphic_item_versions.select {|n| n.graphic_item.class == Mockup and n.graphic_item.end_product.id != self.end_product.id}.empty?
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
