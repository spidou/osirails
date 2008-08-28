class ProductReference < ActiveRecord::Base
  include Permissible
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
  
  # Validation Macros
  validates_presence_of :name, :message => "ne peut être vide"
  
  def after_create
    self.counter_update("create")
  end
  
  def after_destroy
    self.counter_update("destroy")
  end
  
  # This method permit to update counter of parents categories
  def counter_update(index)
    category = ProductReferenceCategory.find(self.product_reference_category_id)
    #if index == "create"
    case index
    when "create"
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => 1)
      end
    when "destroy"
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -1)
      end
    when "disable_or_before_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => -1 
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -1)
      end
    when "after_update"
      ProductReferenceCategory.update_counters category.id, :product_references_count => 1 
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => 1)
      end
    end
  end
    
  # This method permit to check if a reference can be delete or no
  def can_delete?
    #self.products.empty? 
    #FIXME Décommenté quand product sera opérationnel
    false
  end
end
