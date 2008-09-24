class StepGraphicConception < ActiveRecord::Base
  belongs_to :step_commercial
  
  # Plugins
  acts_as_step
end
