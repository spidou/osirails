class PurchaseRequestsController < ApplicationController
  
  def index
    @requests = PurchaseRequest.find(:all, :order => "created_at DESC").paginate(:page => params[:page], :per_page => PurchaseRequest::REQUESTS_PER_PAGE)
  end
  
  def show
    @purchase_request = PurchaseRequest.find(params[:id])
  end
  
  def new
    @purchase_request = PurchaseRequest.new
  end
  
end
