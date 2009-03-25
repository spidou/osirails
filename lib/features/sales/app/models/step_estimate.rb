class StepEstimate < ActiveRecord::Base
  # Relationships
  has_many :estimates
  
  # Plugins
  acts_as_step :parent => :step_commercial, :remarks => false
end
