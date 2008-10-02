class StepInvoicing < ActiveRecord::Base
  belongs_to :order
  
  # Plugins
  acts_as_step
end