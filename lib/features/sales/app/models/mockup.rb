class Mockup < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :cancel]
  has_reference :symbols => [:order], :prefix => :sales
  
  # Relationships
  belongs_to :mockup_type
  belongs_to :product

  # Validations
  validates_presence_of :mockup_type_id, :product_id
  validates_presence_of :mockup_type, :if => :mockup_type_id
  validates_presence_of :product,     :if => :product_id
  
  validates_persistence_of :mockup_type_id, :product_id
  
  validate :validates_inclusion_of_product
  
  def validates_inclusion_of_product
    unless (order.nil? or product.nil?)
      errors.add(:product, I18n.t('activerecord.errors.messages.inclusion')) unless order.products.include?(product)
    end
  end
end
