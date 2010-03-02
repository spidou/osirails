class InvoiceStepController < ApplicationController
  helper :invoices
  
  acts_as_step_controller
end
