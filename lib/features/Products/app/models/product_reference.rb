class ProductReference < ActiveRecord::Base
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :products
  belongs_to :product_reference_category, :counter_cache => true

end
