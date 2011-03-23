class ProductReference < Product
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  has_reference   :symbols => [:product_reference_sub_category], :prefix => :sales
  
  belongs_to :product_reference_sub_category, :counter_cache => true
  
  has_many :end_products
  
  named_scope :actives, :conditions => ["cancelled_at IS NULL"]
  
  validates_presence_of :product_reference_sub_category_id
  validates_presence_of :product_reference_sub_category, :if => :product_reference_sub_category_id
  
  validates_presence_of :reference
  
  validates_persistence_of :product_reference_sub_category_id
  
  before_validation_on_create :update_reference
  
  has_search_index  :only_attributes        => [ :reference, :name, :description ],
                    :additional_attributes  => { :designation => :string },
                    :only_relationships     => [ :product_reference_sub_category ]
  
  PRODUCT_REFERENCES_PER_PAGE = 15
  
  attr_accessor  :product_reference_category_id # correspond to the parent of the product_reference_sub_category associated to the product_reference
  attr_protected :product_reference_category_id # permit to skip the given value from the form
  
  def product_reference_category
    @product_reference_category ||= product_reference_sub_category.product_reference_category if product_reference_sub_category
  end
  
  def product_reference_category_id
    @product_reference_category_id ||= product_reference_category.id if product_reference_category
  end
  
  #TODO test this method
  def can_be_destroyed?
    end_products.empty?
  end
  
  #TODO test this method
  def ancestors
    @ancestors ||= product_reference_sub_category ? [ product_reference_sub_category.product_reference_category, product_reference_sub_category ] : []
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
