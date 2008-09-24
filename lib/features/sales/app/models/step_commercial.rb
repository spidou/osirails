class StepCommercial < ActiveRecord::Base
  # Relationships
  belongs_to :order
  has_one :step_survey
  has_one :step_graphic_conception
  has_one :step_estimate
  
  # Plugins
  acts_as_step
end