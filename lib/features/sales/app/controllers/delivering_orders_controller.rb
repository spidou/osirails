class DeliveringOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:delivering_order_index)
  end
end
