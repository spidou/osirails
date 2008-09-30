class StepEstimate < ActiveRecord::Base
  # Relationships
  belongs_to :step_commercial
  has_many :estimates
  
  # Plugins
  acts_as_step
end