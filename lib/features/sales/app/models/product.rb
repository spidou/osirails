class Product < ActiveRecord::Base
  include ProductBase
  
  has_permissions :as_business_object, :additional_class_methods => [:cancel]
  
  acts_as_list :scope => :order
  
  belongs_to :product_reference, :counter_cache => true
  belongs_to :order
  
  has_many :checklist_responses,  :dependent => :destroy
  has_many :quote_items,          :dependent => :nullify
  has_many :mockups,              :dependent => :nullify
  has_many :press_proofs,         :dependent => :nullify
  
  validates_presence_of :name, :description, :dimensions
  validates_presence_of :order_id, :product_reference_id
  validates_presence_of :order,             :if => :order_id
  validates_presence_of :product_reference, :if => :product_reference_id
  
  #validates_presence_of :reference   #TODO when quote is signed
  #validates_uniqueness_of :reference #TODO when quote is signed
  
  validates_numericality_of :quantity
  validates_numericality_of :unit_price, :prizegiving, :vat, :allow_blank => true
  
  validates_persistence_of :product_reference_id, :order_id
  
  validates_associated :checklist_responses
  
  after_save :save_checklist_responses
  
  before_destroy :cancel_if_cannot_be_destroyed
  
  PRODUCTS_PER_PAGE = 5
  
  attr_accessor :should_destroy
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:product_reference] = "Produit référence :"
  @@form_labels[:name]              = "Nom du produit :"
  @@form_labels[:description]       = "Description :"
  @@form_labels[:dimensions]        = "Côtes :"
  @@form_labels[:quantity]          = "Quantité :"
  
  def should_destroy?
    should_destroy.to_i == 1
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
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  # product cannot be destroyed if it already associated with at least one quote_item, mockup or press_proof
  def can_be_destroyed?
    quote_items.empty? and mockups.empty? and press_proofs.empty?
  end
  
  private
    
    def cancel_if_cannot_be_destroyed
      unless can_be_destroyed?
        self.cancel
        return false
      end
    end
  
end
