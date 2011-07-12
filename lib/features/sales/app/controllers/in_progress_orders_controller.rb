class InProgressOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:in_progress_order_index)
  end
end
