class ProductReference < ActiveRecord::Base
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
  
  def after_create
    self.change("create")
  end
  
  #  def before_update
  #    self.product_reference_category_id = self.old_parent_id
  #    self.change("disable_or_before_update")
  #  end
  #  
  #  def after_update
  #    self.change("after_update")
  #  end
  
  def after_destroy
    self.change("destroy")
  end
  
  # This method permit to update counter of parents categories
  def change(index)
    category = ProductReferenceCategory.find(self.product_reference_category_id)
    if index == "create"
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => 1
      end
    elsif index == "destroy"
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => -1
      end
    elsif index == "disable_or_before_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => -1 
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => -1 
      end
    elsif index == "after_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => 1 
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters parent_category.id, :product_references_count => 1
      end
    end
  end
    
  # This method permit to check if a reference can be delete or no
  def can_delete?
    self.products.empty?
  end
end
