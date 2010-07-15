class PendingPurchaseOrdersController < ApplicationController
  
  helper :purchase_orders, :parcels
  
  def index
    purchase_orders = PurchaseOrder.all
    pending_purchase_orders = []
    for purchase_order in purchase_orders
      if !purchase_order.is_closed_or_cancelled?
        pending_purchase_orders << purchase_order
      end
    end
    @pending_purchase_orders = pending_purchase_orders.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
  end

end
