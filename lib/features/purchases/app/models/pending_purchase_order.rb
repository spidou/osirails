class PendingPurchaseOrder < ActiveRecord::Base
  has_permissions :as_business_object
end
