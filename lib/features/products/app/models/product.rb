class Product < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :product_reference, :counter_cache => true
  
  PRODUCTS_PER_PAGE = 5
end
