class StepSurvey < ActiveRecord::Base
  # Relationships
  belongs_to :step_commercial
  
  # plugins
  has_documents :survey
  acts_as_step({:document_route => ["orders", "step_survey"]})
  
end
