class CommercialOrdersController < ApplicationController
  helper :orders

  def index
    @orders = CommercialStep.orders
  end
end
