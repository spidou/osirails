class ClosedPurchaseOrdersController < ApplicationController

  helper :purchase_orders, :parcels
  
  def index
    if params['filter'] == PurchaseOrder::STATUS_CANCELLED
      purchase_orders = PurchaseOrder.all
      closed_purchase_orders = []
      for purchase_order in purchase_orders
        if purchase_order.is_closed_or_cancelled?
          closed_purchase_orders << purchase_order
        end
      end
      @closed_purchase_orders = closed_purchase_orders.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    else
      purchase_orders = PurchaseOrder.all
      closed_purchase_orders = []
      for purchase_order in purchase_orders
        if purchase_order.was_completed?
          closed_purchase_orders << purchase_order
        end
      end
      @closed_purchase_orders = closed_purchase_orders.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    end
  end

end
