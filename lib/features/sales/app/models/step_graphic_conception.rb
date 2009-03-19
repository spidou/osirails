class StepGraphicConception < ActiveRecord::Base
  # Relationships
  belongs_to :step_commercial
  has_many :press_proofs
  
  # plugins
  has_documents :graphic_charter
  acts_as_step :document_route => ["orders", "graphic_conception"]
end
