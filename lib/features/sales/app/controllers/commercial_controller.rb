class CommercialController < ApplicationController
  def index
    @orders = Order.find(:all)
  end
end