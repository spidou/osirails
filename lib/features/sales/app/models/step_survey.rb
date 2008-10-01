class StepSurvey < ActiveRecord::Base
  include Permissible
  
  belongs_to :step_commercial
  
  # Plugins
  acts_as_step
  
end
