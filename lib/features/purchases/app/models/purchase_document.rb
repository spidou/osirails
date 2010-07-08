class PurchaseDocument < ActiveRecord::Base
  
  has_permissions :as_business_object
  
  belongs_to :purchase_order_supply
end
