class StepCommercial < ActiveRecord::Base
  has_one :step_survey
  has_one :step_graphic_conception
  has_one :estimate
end