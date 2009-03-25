class CommercialController < ApplicationController
  helper :orders
  
  def index
    @orders = StepCommercial.find(:all, :conditions => "status <> 'terminated'").collect { |sc| sc.order }
  end
  
  def show

  end
  
  def edit

  end
end
