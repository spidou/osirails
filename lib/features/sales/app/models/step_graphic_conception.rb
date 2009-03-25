class StepGraphicConception < ActiveRecord::Base
  has_many :press_proofs
  
  # plugins
  has_documents :graphic_charter
  acts_as_step :parent => :step_commercial
end
