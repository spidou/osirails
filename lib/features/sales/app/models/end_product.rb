class EndProduct < Product
  include ProductBase
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference   :symbols => [:product_reference], :prefix => :sales
  
  belongs_to :product_reference, :counter_cache => true
  belongs_to :order
  
  has_many :checklist_responses, :dependent => :destroy
  has_many :quote_items,         :dependent => :nullify
  has_many :mockups,             :dependent => :nullify
  has_many :press_proofs,        :dependent => :nullify, :order => 'created_at DESC'
  
  acts_as_list :scope => :order
  
  validates_presence_of :product_reference_id, :order_id
  validates_presence_of :product_reference, :if => :product_reference_id
  validates_presence_of :order,             :if => :order_id
  
  validates_presence_of :reference
  
  validates_numericality_of :quantity
  validates_numericality_of :prizegiving, :allow_nil => true
  validates_numericality_of :vat, :if => Proc.new{ |p| p.quote_items.reject{ |i| i.quote.cancelled? }.any? } # run validation if product is associated with at least 1 quote_item which provide from a non-cancelled quote
  
  validates_persistence_of :product_reference_id, :order_id
  
  validates_associated :checklist_responses
  
  before_validation_on_create :update_reference
  
  after_save :save_checklist_responses
  
  attr_accessor :should_destroy
  
  END_PRODUCTS_PER_PAGE = 15
  
  @@form_labels[:quantity] = "Quantité :"
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
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
    @designation ||= name + ( dimensions.blank? ? "" : " (#{dimensions})" )
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
