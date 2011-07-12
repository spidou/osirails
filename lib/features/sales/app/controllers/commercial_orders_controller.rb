class CommercialOrdersController < ApplicationController
  helper :orders

  def index
    build_query_for(:commercial_order_index)
  end
end
