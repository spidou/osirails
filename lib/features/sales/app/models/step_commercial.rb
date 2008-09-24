class StepCommercial < ActiveRecord::Base
  # Relationships
  has_one :step_survey
  has_one :step_graphic_conception
  has_one :estimate
  
  # Plugins
  acts_as_step
end