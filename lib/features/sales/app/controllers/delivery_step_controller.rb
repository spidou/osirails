class DeliveryStepController < ApplicationController
  helper :delivery_notes
  
  acts_as_step_controller
end
