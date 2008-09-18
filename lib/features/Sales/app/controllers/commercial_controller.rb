class CommercialController < ApplicationController
  def index
    @orders = Order.find(:all)
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def new
    @order = Order.new
  end
  
  def edit
    @order = Order.find(params[:id])
  end
  
  def create
    @order = Order.create(params[:order])
  end
  
  def update
    @order = Order.find(params[:id])
    @order.update_attributes(params[:order])
  end
  
  def destroy
    @order = params[:id]
    @order.destroy
  end
end