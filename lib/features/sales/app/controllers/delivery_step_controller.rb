class DeliveryStepController < ApplicationController
  helper :delivery_notes, :delivery_interventions
  
  acts_as_step_controller
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]
end
