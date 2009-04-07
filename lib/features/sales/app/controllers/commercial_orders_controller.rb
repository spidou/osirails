class CommercialOrdersController < ApplicationController
  helper :orders

  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }
  end
end
