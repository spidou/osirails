class ProductReference < Product
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference   :symbols => [:product_reference_category], :prefix => :sales
  
  belongs_to :product_reference_category, :counter_cache => true
  
  has_many :end_products
  
  named_scope :actives, :conditions => ["cancelled_at IS NULL"]
  
  validates_presence_of :product_reference_category_id
  validates_presence_of :product_reference_category, :if => :product_reference_category_id
  
  validates_presence_of :reference
  
  validates_persistence_of :product_reference_category_id
  
  validate :validates_product_reference_category_has_parent_category
  
  before_validation_on_create :update_reference
  
  has_search_index  :only_attributes      => [ :reference, :name, :description ],
                    :only_relationships   => [ :product_reference_category ]
  
  PRODUCT_REFERENCES_PER_PAGE = 15
  
  @@form_labels[:product_reference_category] = "Sous-famille :"
  
  def validates_product_reference_category_has_parent_category
    errors.add(:product_reference_category_id, ActiveRecord::Errors.default_error_messages[:inclusion]) if product_reference_category and product_reference_category.ancestors.empty?
  end
  
  #TODO test this method
  def can_be_destroyed?
    end_products.empty?
  end
  
  #TODO test this method
  def ancestors
    @ancestors ||= product_reference_category ? product_reference_category.ancestors + [ product_reference_category ] : []
  end
  
  def designation
    @designation ||= (ancestors + [self]).collect(&:name).join(" ") + ( dimensions.blank? ? "" : " (#{dimensions})" )
  end
  
#  def after_create
#    self.counter_update("create")
#  end
#  
#  def after_destroy
#    self.counter_update("destroy")
#  end
#  
#  # This method permit to update counter of parents categories
#  def counter_update(index)
#    category = ProductReferenceCategory.find(self.product_reference_category_id)
#    case index
#    when "create"
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => 1)
#      end
#    when "destroy"
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -1)
#      end
#    when "disable_or_before_update"
#      ProductReferenceCategory.update_counters category.id, :product_references_count => -1 
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -1)
#      end
#    when "after_update"
#      ProductReferenceCategory.update_counters category.id, :product_references_count => 1 
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => 1)
#      end
#    end
#  end
end
