class PaymentStepController < ApplicationController
  helper :invoices
  
  acts_as_step_controller
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]
end
