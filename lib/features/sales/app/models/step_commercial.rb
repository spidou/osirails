class StepCommercial < ActiveRecord::Base
  acts_as_step :children => [ :step_survey, :step_graphic_conception, :step_estimate ]
end
