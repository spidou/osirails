class ClosedPurchaseOrder < ActiveRecord::Base
  has_permissions :as_business_object
  
  REQUESTS_PER_PAGE = 10
end
