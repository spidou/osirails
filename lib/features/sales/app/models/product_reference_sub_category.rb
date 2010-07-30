class ProductReferenceSubCategory < ProductReferenceCategory
  has_permissions :as_business_object
  has_reference   :symbols => [:product_reference_category], :prefix => :sales
  
  belongs_to :product_reference_category
  
  has_many :product_references, :conditions => [ "cancelled_at IS NULL" ]
  has_many :disabled_product_references, :class_name => "ProductReference", :conditions => [ "cancelled_at IS NOT NULL" ]
  has_many :all_product_references, :class_name => "ProductReference"
  
  #has_search_index  :only_attributes      => [ :reference, :name ],
  #                  :only_relationships   => [ :product_reference_category ]
  
  validates_persistence_of :product_reference_category_id, :unless => :can_update_product_reference_category_id?
  
  before_validation_on_create :update_reference
  
  @@form_labels[:product_reference_category] = "Famille parente :"
  
  #TODO test that method
  def can_update_reference?
    all_product_references.empty?
  end
  
  #TODO test that method
  def can_update_product_reference_category_id?
    all_product_references.empty?
  end
  
  #TODO test that method
  def can_be_destroyed?
    product_references.empty?
  end
  
  #TODO test that method
  def product_references_count
    self[:product_references_count]
  end
  
  #TODO test that method
  def children
    product_references
  end
  
  #TODO test that method
  def disabled_children
    disabled_product_references
  end
  
  #TODO test that method
  def has_disabled_children?
    disabled_children.any?
  end
end
