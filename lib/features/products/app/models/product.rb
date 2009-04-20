class Product < ActiveRecord::Base
  has_permissions :as_business_object

  # Relationships
  belongs_to :product_reference, :counter_cache => true

  # Validations
  validates_presence_of :name, :product_reference_id
  
  PRODUCTS_PER_PAGE = 5
end
