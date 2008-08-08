class ProductReference < ActiveRecord::Base
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
  
  def after_create
    self.change("up")
  end
  
  def after_update
    self.change_count
  end
  
  def after_destroy
    self.change("down")
  end
  
  # This method permit to remove the reference in counter of this parents
  def change_count
    old_category = ProductReferenceCategory.find(self.product_reference_category_id)
    ProductReferenceCategory.update_counters old_category.id, :product_references_count => -1
    old_category.ancestors.each do |category|
      ProductReferenceCategory.update_counters category.id, :product_references_count => -1
    end
  end

  def change(index)
    if index == "up"
      old_category = ProductReferenceCategory.find(self.product_reference_category_id)
      old_category.ancestors.each do |category|
        ProductReferenceCategory.update_counters category.id, :product_references_count => 1
      end
    elsif index == "down"
      old_category = ProductReferenceCategory.find(self.product_reference_category_id)
      old_category.ancestors.each do |category|
        ProductReferenceCategory.update_counters category.id, :product_references_count => -1
      end
    end
    
  end
    
  # This method permit to check if a reference can be delete or no
  def can_delete?
    #  self.products.empty?
true
  end
end
