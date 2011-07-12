class ProductionOrdersController < ApplicationController
  helper :orders
  
  # GET /production_orders
  def index
    build_query_for(:production_order_index)
  end
end
