class CommercialController < ApplicationController
  helper :orders

  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }
  end

  def show
    @order = Order.find(params[:order_id])
    
    #OPTIMIZE this is not right! graphic_conception would not be the first step of the commercial step => make a redirection more generic!
    redirect_to order_path(@order) + '/' + (@order.step_commercial.terminated? ? 'graphic_conception' : @order.current_step.path)
  end
end
