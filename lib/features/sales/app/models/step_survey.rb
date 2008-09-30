class StepSurvey < ActiveRecord::Base
  include Permissible
  
  belongs_to :step_commercial
  
  # Plugins
  acts_as_step
  acts_as_file
  
  def checklists
    s = Step.find_by_name(self.class.name.tableize.singularize)
    s.checklists
  end
end
