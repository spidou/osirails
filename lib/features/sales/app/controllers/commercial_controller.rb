class CommercialController < ApplicationController
  def index
    @orders = []
    Order.find(:all).each {|order| @orders << order if order.step = ""}
  end
end