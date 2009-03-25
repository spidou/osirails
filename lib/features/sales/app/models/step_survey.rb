class StepSurvey < ActiveRecord::Base  
  
  has_documents :photo
  acts_as_step :parent => :step_commercial
  
end
