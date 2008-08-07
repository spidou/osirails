class ProductReferenceCategory < ActiveRecord::Base
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :product_references
  has_many :product_reference_categories
  

end
