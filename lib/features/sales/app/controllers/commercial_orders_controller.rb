class CommercialOrdersController < ApplicationController
  helper :orders

  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }.sort_by{ |order| order.previsional_delivery }
  end
end
