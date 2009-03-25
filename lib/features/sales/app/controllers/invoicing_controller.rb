class InvoicingController < ApplicationController
  helper :orders

  def index
    @orders = StepInvoicing.find(:all, :conditions => "status <> 'terminated'").collect { |si| si.order }
  end

  def show
    @order = Order.find(params[:order_id])
  end

  def edit
  end
end
