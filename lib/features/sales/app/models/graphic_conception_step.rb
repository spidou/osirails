class GraphicConceptionStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  has_documents :graphic_charter
  
  has_many :press_proofs
end
