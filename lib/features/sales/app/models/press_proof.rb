class PressProof < ActiveRecord::Base
  
  belongs_to :step_graphic_conception
  
  ## Plugins
  acts_as_file
  
end