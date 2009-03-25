class LogsController < ApplicationController
  acts_as_step_controller :sham => true

  before_filter :select_menu

  def index
    @logs = @order.order_logs.paginate  :per_page => 20,
                                        :page => params[:page],
                                        :order => 'created_at DESC'
  end

  def show
    @log = OrderLog.find(params[:id])
  end

  private

  def select_menu
    @@current_order_step = @order.current_step.first_parent.path
  end
end
