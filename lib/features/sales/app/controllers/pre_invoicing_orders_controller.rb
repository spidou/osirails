class PreInvoicingOrdersController < ApplicationController
  helper :orders

  def index
    @orders = PreInvoicingStep.orders
  end
end
