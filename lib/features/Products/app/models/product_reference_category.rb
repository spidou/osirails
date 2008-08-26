class ProductReferenceCategory < ActiveRecord::Base
  include Permissible
 
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :product_references
  has_many :product_reference_categories
  
  # Validation Macros
  validates_presence_of :name, :message => "ne peut être vide"

  # This method permit to update counter of parents categories
  def counter_update(index,value)
    category = ProductReferenceCategory.find(self.id)
    if index == "before_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => -value
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => -value 
      end
    elsif index == "after_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => value
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => value
      end
    end
  end
  
  # This method permit to check if a category can have a new parent category
  def can_has_this_parent?(new_parent_category_id)
    return true if new_parent_category_id == "" or new_parent_category_id.nil?
    new_parent = ProductReferenceCategory.find(new_parent_category_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self)
    true
  end
  
  # This method permit to change category
  def change_category(new_parent_category_id)
    if self.can_has_this_parent?(new_parent_category_id) and new_parent_category_id.to_s != self.product_reference_category_id.to_s
      self.product_reference_category_id = new_parent_category_id
      self.save
    end
  end
  
  # This method permit to check if category can be deleted or no
  def can_delete?
    self.product_references.empty? and self.product_reference_categories.empty?
  end
  
end