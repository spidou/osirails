class Mockup < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :cancel]
  has_reference :symbols => [:order], :prefix => :sales
  
  # Relationships
  belongs_to :mockup_type
  belongs_to :end_product

  # Validations
  validates_presence_of :mockup_type_id, :end_product_id
  validates_presence_of :mockup_type, :if => :mockup_type_id
  validates_presence_of :end_product, :if => :end_product_id
  
  validates_persistence_of :mockup_type_id, :end_product_id
  
  validate :validates_inclusion_of_end_product
  
  def validates_inclusion_of_end_product
    unless (order.nil? or end_product.nil?)
      errors.add(:end_product, I18n.t('activerecord.errors.messages.inclusion')) unless order.end_products.include?(end_product)
    end
  end
end
