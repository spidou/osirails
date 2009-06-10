class InvoicingStepController < ApplicationController
  acts_as_step_controller :sham => true

  def index
    if @order.invoicing_step.terminated?
      step_to_display = @order.invoicing_step.children_steps.last
    else
      step_to_display = @order.invoicing_step.children_steps.select{ |s| !s.terminated? }.first # there is at least one child unterminated if the parent step is not terminated
    end
    redirect_to send(step_to_display.original_step.path)
  end
end
