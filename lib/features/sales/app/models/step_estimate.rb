class StepEstimate < ActiveRecord::Base
  # Relationships
  has_many :quotes
  
  validates_associated :quotes
  
  # Plugins
  acts_as_step :remarks => false, :checklists => false
end
