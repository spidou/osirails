class ClosedOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:closed_order_index)
  end
end
