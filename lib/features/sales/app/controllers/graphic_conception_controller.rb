class GraphicConceptionsController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check, :except => [:index]
  
  def show
    
  end
  
  def edit
    
  end
  
  protected
  
  def check
    @order = Order.find(params[:id])
    @current_order_step = @order.step.name
  end
end