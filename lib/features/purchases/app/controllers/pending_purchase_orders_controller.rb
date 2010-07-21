class PendingPurchaseOrdersController < ApplicationController
  
  helper :purchase_orders, :parcels
  
  def index
    @pending_purchase_orders = PurchaseOrder.pending.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
  end

end
