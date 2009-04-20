class StepGraphicConception < ActiveRecord::Base
  # Relationships
  belongs_to :step_commercial
  has_many :press_proofs

  # Validations
  validates_presence_of :commercial_id

  # Plugins
  acts_as_step({:document_route => ["orders", "graphic_conception"]})
end
