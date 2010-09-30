class ProductionOrdersController < ApplicationController
  include AdjustPdf
  helper :orders, :production_steps
  
  # GET /sales/production_managements/
  def index
    @orders = ProductionStep.orders
  end
end
