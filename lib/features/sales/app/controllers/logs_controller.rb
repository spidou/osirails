class LogsController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check
  
  def index
    @logs = @order.order_logs.paginate  :per_page => 20,
                                        :page => params[:page],
                                        :order => 'created_at DESC'
  end
  
  def show
    @log = OrderLog.find(params[:id])
  end
  
  protected
  
  def check
    @order = Order.find(params[:order_id])
  end
end