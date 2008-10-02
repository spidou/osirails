class InformationsController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check, :except => [:index]
  
  def show
    
  end
  
  protected
  
  def check
    @order = Order.find(params[:order_id])
    OrderLog.set(@order, current_user, params) # Manage logs
  end
end