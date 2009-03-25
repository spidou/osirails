class CommercialController < ApplicationController
  helper :orders

  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }
  end

  def show
    @order = Order.find(params[:order_id])
    redirect_to order_path(@order) + '/' + (@order.step_commercial.terminated? ? 'graphic_conception' : @order.current_step.path)
  end
end
