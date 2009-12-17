class Mockup < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :delete, :cancel]
  
  # Relationships
  belongs_to :mockup_type
   # TODO when it will be implemented, belongs_to :press_proof
  belongs_to :product

  # Validations
  validates_presence_of :mockup_type_id, :product_id #TODO add the press proof id when it will be implemented
  validates_presence_of :mockup_type, :if => :mockup_type_id
  validates_presence_of :product, :if => :product_id
  # TODO when it will be implemented, validates_presence_of :press_proof, :if => :press_proof_id
  validates_persistence_of :mockup_type_id, :product_id #TODO add the press proof when it will be implemented
  validate :validates_inclusion_of_product
  
  def validates_inclusion_of_product
    unless (order.nil? or product.nil?)
      errors.add(:product,ActiveRecord::Errors.default_error_messages[:inclusion]) unless order.products.include?(product)
    end
  end
end
