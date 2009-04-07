class StepCommercialController < ApplicationController
  helper :orders

  def index
    @order = Order.find(params[:order_id])
    if @order.step_commercial.terminated?
      step_to_display = @order.step_commercial.children_steps.last
    else
      step_to_display = @order.step_commercial.children_steps.select{ |s| !s.terminated? }.first # there is at least one child unterminated if the parent step is not terminated
    end
    redirect_to send("order_step_#{step_to_display.original_step.path}_path")
  end
end
