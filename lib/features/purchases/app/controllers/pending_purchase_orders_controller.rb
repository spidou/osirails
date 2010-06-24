class PendingPurchaseOrdersController < ApplicationController
  
  helper :purchase_orders, :parcels
  
  def index
    @pending_purchase_orders = PurchaseOrder.all(:conditions => ["(status is null) or (status = ?) or (status = ?)", PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING]).paginate(:page => params[:page], :per_page => PendingPurchaseOrder::REQUESTS_PER_PAGE)
  end

end
