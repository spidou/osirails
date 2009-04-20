class StepSurvey < ActiveRecord::Base
  # Relationships
  belongs_to :step_commercial

  # Validations
  validates_presence_of :commercial_id

  # Plugins
  acts_as_step({:document_route => ["orders", "step_survey"]})
  
end
