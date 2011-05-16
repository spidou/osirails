class ProductionOrdersController < ApplicationController
  helper :orders
  
  # GET /production_orders
  def index
    @orders = ProductionStep.orders
  end
end
