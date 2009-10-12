class SurveyStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  has_documents :photo
end
