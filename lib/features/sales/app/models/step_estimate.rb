class StepEstimate < ActiveRecord::Base
  # Relationships
  has_many :quotes
  
  # Plugins
  acts_as_step :remarks => false
end
