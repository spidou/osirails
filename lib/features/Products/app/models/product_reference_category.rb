class ProductReferenceCategory < ActiveRecord::Base
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :product_references
  has_many :product_reference_categories
  
  def after_update
    
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