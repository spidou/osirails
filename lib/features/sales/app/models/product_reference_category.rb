class ProductReferenceCategory < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :product_reference_sub_categories, :conditions => [ "cancelled_at IS NULL" ]
  has_many :disabled_product_reference_sub_categories, :class_name => "ProductReferenceSubCategory", :conditions => [ "cancelled_at IS NOT NULL" ]
  has_many :all_product_reference_sub_categories, :class_name => "ProductReferenceSubCategory"
  
  named_scope :roots,   :conditions => [ "type IS NULL" ]
  named_scope :actives, :conditions => ["cancelled_at IS NULL"]
  
  validates_presence_of :reference, :name
  
  validates_uniqueness_of :name, :scope => :type, :case_sensitive => false
  validates_uniqueness_of :reference, :case_sensitive => false
  
  validates_persistence_of :reference, :unless => :can_update_reference?
  
  has_search_index  :only_attributes    => [ :reference, :name ],
                    :only_relationships => [ :product_reference_sub_categories ]
  
  before_destroy :can_be_destroyed?
  
  attr_protected :cancelled_at
  
  #TODO test that method
  def enabled?
    !cancelled_at
  end
  
  #TODO test that method
  def was_enabled?
    !cancelled_at_was
  end
  
  #TODO test that method
  def can_update_reference?
    all_product_reference_sub_categories.empty?
  end
  
  #TODO test that method
  def can_be_disabled?
    was_enabled?
  end
  
  #TODO test that method
  def can_be_destroyed?
    product_reference_sub_categories.empty?
  end
  
  #TODO test that method
  def disable
    if can_be_disabled?
      self.cancelled_at = Time.now
      self.save
    end
  end
  
  #TODO test that method
  def reference_and_name
    @reference_and_name ||= "#{reference} - #{name}"
  end
  
  #TODO test that method
  def product_references_count
    product_reference_sub_categories.collect(&:product_references_count).sum
  end
  
#  # This method permit to update counter of parents categories
#  def counter_update(index,value)
#    category = ProductReferenceCategory.find(self.id)
#    case index
#    when "before_update"
#      ProductReferenceCategory.update_counters(category.id, :product_references_count => -value)
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -value)
#      end
#    when "after_update"
#      ProductReferenceCategory.update_counters(category.id, :product_references_count => value)
#      category.ancestors.each do |parent_category|
#        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => value)
#      end
#    end
#  end
  
#  # This method permit to check if a category can have a new parent category
#  def can_has_this_parent?(new_parent_category_id)
#    return true if new_parent_category_id.blank?
#    new_parent = ProductReferenceCategory.find(new_parent_category_id)
#    return false if new_parent.id == self.id or new_parent.ancestors.include?(self)
#    true
#  end
  
  #TODO test that method
  def children
    product_reference_sub_categories
  end
  
  #TODO test that method
  def disabled_children
    disabled_product_reference_sub_categories
  end
  
  #TODO test that method
  def has_disabled_children?
    disabled_children.any?
  end
  
end
