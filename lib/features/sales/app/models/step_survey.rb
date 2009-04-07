class StepSurvey < ActiveRecord::Base  
  
  has_documents :photo
  acts_as_step
  
end
