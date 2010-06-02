class PurchaseRequestsController < ApplicationController
  
  def index
    @requests = PurchaseRequest.all(:order => "created_at DESC")
  end
end
