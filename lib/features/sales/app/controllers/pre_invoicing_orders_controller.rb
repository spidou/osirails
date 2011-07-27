class PreInvoicingOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:pre_invoicing_order_index)
  end
end
