class PendingPurchaseOrdersController < ApplicationController
  
  helper :purchase_orders, :purchase_deliveries
  
  # GET /pending_purchase_orders
  # GET /pending_purchase_orders?page=:page
  def index
    @pending_purchase_orders = PurchaseOrder.pending.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
  end

end
