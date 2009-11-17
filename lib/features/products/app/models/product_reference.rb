class ProductReference < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
  
  # Validation Macros
  validates_presence_of :name, :reference, :message => "ne peut être vide"
  validates_uniqueness_of :reference, :message => "doit être unique"
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:reference] = "Référence :"
  @@form_labels[:name] = "Nom :"
  @@form_labels[:description] = "Description :"
  @@form_labels[:information] = "Informations complémentaires :"
  @@form_labels[:product_reference_category] = "Famille de produit :"
  @@form_labels[:production_cost_manpower] = "Coût de main-d'oeuvre :"
  @@form_labels[:production_time] = "Durée :"
  @@form_labels[:delivery_cost_manpower] = "Coût de main-d'oeuvre :"
  @@form_labels[:delivery_time] = "Durée :"
  
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
end
