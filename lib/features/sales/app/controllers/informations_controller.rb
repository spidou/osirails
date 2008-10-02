class InformationsController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check, :except => [:index]
  before_filter :logs
  
  def show
    
  end
  
  protected
  
  def logs
    OrderLog.set(@order, current_user, params)
  end
  
  def check
    @order = Order.find(params[:order_id])
  end
end