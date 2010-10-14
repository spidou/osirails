class PurchaseRequestSuppliesController < ApplicationController
  
  helper :purchase_requests, :purchase_orders
  
  # GET /purchase_request_supplies
  def index  
    @purchase_request_supplies = PurchaseRequestSupply.sorted_by_priority_and_expected_delivery_date.paginate(:page => params[:page], :per_page => PurchaseRequest::REQUESTS_PER_PAGE)
  end
end
