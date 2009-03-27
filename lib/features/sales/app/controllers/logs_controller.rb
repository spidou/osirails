class LogsController < ApplicationController
  acts_as_step_controller :sham => true

  def index
    @logs = @order.order_logs.paginate  :per_page => 20,
                                        :page => params[:page],
                                        :order => 'created_at DESC'
  end

  def show
    @log = OrderLog.find(params[:id])
  end
end
