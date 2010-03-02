class DeliveryStepController < ApplicationController
  helper :delivery_notes, :delivery_interventions
  
  acts_as_step_controller
end
