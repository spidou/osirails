class ProductReference < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
  
  # Validation Macros
  validates_presence_of :name, :reference
  validates_uniqueness_of :reference
  
  has_search_index  :only_attributes      => [:reference, :name, :description],
                    :only_relationships   => [:product_reference_category],
                    :main_model           => true
  
  def after_create
    self.counter_update("create")
  end
  
  def after_destroy
    self.counter_update("destroy")
  end
  
  # This method permit to update counter of parents categories
  def counter_update(index)
    category = ProductReferenceCategory.find(self.product_reference_category_id)
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
    
  # This method permit to check if a reference should be deleted or not
  def can_be_destroyed?
    self.products.empty?
  end
  
  def designation
    ancestors_names.join(" ") + " " + name
  end
  
  def ancestors_names
    if product_reference_category
      (product_reference_category.ancestors.reverse + [product_reference_category]).collect(&:name)
    else
      []
    end
  end
  
  #FIXME DELETEME? Is this method really logical ?
  ## calculate unit price of the product reference according to production and delivery costs
  #def unit_price
  #  price = 0
  #  if production_cost_manpower and production_time
  #    price = production_cost_manpower * production_time
  #  end
  #  
  #  if delivery_cost_manpower and delivery_time
  #    price += delivery_cost_manpower * delivery_time
  #  end
  #  
  #  price
  #end
end
