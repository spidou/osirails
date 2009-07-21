class ProductReference < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true
#  has_many :quotes_product_references, :dependent => :nullify
#  has_many :quotes, :through => :quotes_product_references
  
  # Validation Macros
  validates_presence_of :name, :reference
  validates_uniqueness_of :reference
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:reference] = "R&eacute;f&eacute;rence :"
  @@form_labels[:name] = "Nom :"
  @@form_labels[:description] = "Description :"
  @@form_labels[:information] = "Informations complémentaires :"
  @@form_labels[:product_reference_category] = "Famille de produit :"
  @@form_labels[:vat] = "TVA à appliquer (%) :"
  @@form_labels[:production_cost_manpower] = "Coût horaire de main-d'oeuvre :"
  @@form_labels[:production_time] = "Durée (en heures) :"
  @@form_labels[:delivery_cost_manpower] = "Coût horaire de main-d'oeuvre :"
  @@form_labels[:delivery_time] = "Durée (en heures) :"
  
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
  
  # calculate unit price of the product reference according to production and delivery costs
  def unit_price
    price = 0
    if production_cost_manpower and production_time
      price = production_cost_manpower * production_time
    end
    
    if delivery_cost_manpower and delivery_time
      price += delivery_cost_manpower * delivery_time
    end
    
    price
  end
end
