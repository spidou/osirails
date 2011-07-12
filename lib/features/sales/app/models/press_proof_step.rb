class PressProofStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  has_search_index :only_attributes => [ :status, :started_at, :finished_at ]
end
