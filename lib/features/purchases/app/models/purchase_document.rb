class PurchaseDocument < ActiveRecord::Base
  
  has_permissions :as_business_object
  
  has_one :parcel
end
