class PressProof < ActiveRecord::Base
  
  belongs_to :graphic_conception_step
  
  ## Plugins
  #acts_as_file
  
end
