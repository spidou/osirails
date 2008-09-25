class Product < ActiveRecord::Base
  # Relationship
  belongs_to :product_reference, :counter_cache => true
  
  PRODUCTS_PER_PAGE = 5
end
