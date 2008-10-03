class StepSurvey < ActiveRecord::Base
  
  belongs_to :step_commercial
  
  # Plugins
  acts_as_step({:document_route => ["orders", "step_survey"]})
  
end
