class ClosedOrdersController < ApplicationController
  helper :orders

  def index
    @orders = []
  end
end
