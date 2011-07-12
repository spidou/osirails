class InvoicingOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:invoicing_order_index)
  end
end
