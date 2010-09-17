class EndProduct < Product
  include ProductBase
  
  # TODO remove cancelled_at once journalization is ready to use
  #      add column 'status' in products
  #      uncomment the following lines to enable status
  # STATUS_DRAFT      = 0 # in an order which has no quote
  # STATUS_ABANDONED  = 1 # hasn't been taken by customer
  # STATUS_PENDING    = 2 # in an order which has an unsigned quote
  # STATUS_SOLD       = 3 # in an order which has a signed quote
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference   :symbols => [:product_reference], :prefix => :sales
  
  belongs_to :product_reference, :counter_cache => true
  belongs_to :order
  
  has_many :checklist_responses, :dependent => :destroy
  has_many :quote_items,         :dependent => :nullify
  has_many :quotes,              :through   => :quote_items
  has_many :mockups,             :dependent => :nullify
  has_many :press_proofs,        :dependent => :nullify, :order => 'created_at DESC'
  
  acts_as_list :scope => :order
  
  validates_presence_of :product_reference_id, :order_id
  validates_presence_of :product_reference, :if => :product_reference_id
  validates_presence_of :order,             :if => :order_id
  
  validates_presence_of :reference
  
  validates_numericality_of :quantity
  validates_numericality_of :prizegiving, :allow_nil => true
  #TODO find a way to validate numericality of vat without 'quote_items'
  #validates_numericality_of :vat, :if => Proc.new{ |p| p.quote_items.reject{ |i| i.quote.cancelled? }.any? } # run validation if product is associated with at least 1 quote_item which coming from a non-cancelled quote
  
  validates_persistence_of :product_reference_id, :order_id
  
  validates_associated :checklist_responses
  
  before_validation_on_create :update_reference
  
  after_save :save_checklist_responses
  
  END_PRODUCTS_PER_PAGE = 15
  
  @@form_labels[:product_reference] = "Produit référence :"
  @@form_labels[:quantity]          = "Quantité :"
  
  def name
    self[:name] ||= product_reference ? product_reference.designation : nil
  end
  
  def description
    self[:description] ||= product_reference ? product_reference.description : nil
  end
  
  def dimensions
    self[:dimensions] ||= product_reference ? product_reference.dimensions : nil
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def can_be_cancelled?
    quotes(true).actives.empty?
  end
  
  def can_be_deleted?
    quotes(true).empty?
  end
  
  #TODO test that method
  def has_signed_press_proof?
    #OPTIMIZE use a sql statement instead
    press_proofs.select{ |n| n.was_signed? }.any?
  end
  
  #TODO test this method
  def ancestors
    @ancestors ||= product_reference ? product_reference.ancestors + [ product_reference ] : []
  end
  
  def designation
    return unless name
    name + ( dimensions.blank? ? "" : " (#{dimensions})" )
  end
  
  def checklist_responses_attributes=(checklist_responses_attributes)
    checklist_responses_attributes.each do |attributes|
      if attributes[:id].blank?
        checklist_responses.build(attributes) unless attributes[:answer].blank?
      else
        checklist_response = checklist_responses.detect { |t| t.id == attributes[:id].to_i }
        checklist_response.attributes = attributes
      end
    end
  end
  
  def save_checklist_responses
    checklist_responses.each do |r|
      if r.answer.blank?
        r.destroy
      elsif r.changed?
        r.save(false)
      end
    end
  end
end
