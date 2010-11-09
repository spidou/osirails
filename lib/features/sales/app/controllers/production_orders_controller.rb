class ProductionOrdersController < ApplicationController
  helper :orders, :manufacturing_steps
  
  # GET /production_orders
  def index
    @orders = ProductionStep.orders
  end
end
