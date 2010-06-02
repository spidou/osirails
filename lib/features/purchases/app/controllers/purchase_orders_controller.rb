class PurchaseOrdersController < ApplicationController

  def index
    @requests = PurchaseRequest.all
  end
  
end
