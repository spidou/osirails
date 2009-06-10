class GraphicConceptionStep < ActiveRecord::Base
  acts_as_step
  has_documents :graphic_charter
  
  has_many :press_proofs
end
