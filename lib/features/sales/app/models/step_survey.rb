class StepSurvey < ActiveRecord::Base
  
  belongs_to :step_commercial
  
  # Plugins
  acts_as_step
  acts_as_file
  
end
