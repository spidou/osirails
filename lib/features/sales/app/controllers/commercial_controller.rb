class CommercialController < ApplicationController
  attr_accessor :current_order_step
  before_filter :check, :except => [:index]
  
  helper 'orders'
  
  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }
  end
  
  def show

  end
  
  def edit

  end
  
  protected
  
  def check
    @order = Order.find(params[:order_id])
    OrderLog.set(@order, current_user, params) # Manage logs
  end
end