class SurveyStep < ActiveRecord::Base  
  acts_as_step
  has_documents :photo
end
