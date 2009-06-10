class InvoicingOrdersController < ApplicationController
  helper :orders

  def index
    @orders = InvoicingStep.orders
  end
end
