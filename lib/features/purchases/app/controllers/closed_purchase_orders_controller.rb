class ClosedPurchaseOrdersController < ApplicationController

  helper :purchase_orders, :purchase_deliveries
  
  # GET /closed_purchase_orders
  # GET /closed_purchase_orders?filter=completed_only
  
  def index
    if params['filter'] == "completed_only"
      @closed_purchase_orders = PurchaseOrder.completed.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    else
      @closed_purchase_orders = PurchaseOrder.closed.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    end
  end

end
