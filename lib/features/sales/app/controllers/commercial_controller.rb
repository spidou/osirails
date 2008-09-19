class CommercialController < ApplicationController
  helper 'orders'
  
  def index
    #@orders = []
    #Order.find(:all).each {|order| @orders << order if order.step = ""}
    @orders = Order.find(:all)
  end
  
  def new
    @order = Order.new
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def edit
    @order = Order.find(params[:id])
  end
end