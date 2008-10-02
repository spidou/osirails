class StepGraphicConception < ActiveRecord::Base
  
  belongs_to :step_commercial
  has_many :press_proofs
  
  # Plugins
  acts_as_step
end
