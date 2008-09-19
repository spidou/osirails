class Product < ActiveRecord::Base
  # Relationship
  belongs_to :product_reference, :counter_cache => true
end
