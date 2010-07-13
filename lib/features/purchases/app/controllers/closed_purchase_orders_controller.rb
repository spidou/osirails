class ClosedPurchaseOrdersController < ApplicationController

  helper :purchase_orders, :parcels
  
  def index
    @closed_purchase_orders = PurchaseOrder.all(:conditions => ["status = ?", PurchaseOrder::STATUS_COMPLETED]).paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    if params['filter'] == PurchaseOrder::STATUS_CANCELLED
      @closed_purchase_orders = PurchaseOrder.all(:conditions => ["status = ? or status = ?", PurchaseOrder::STATUS_COMPLETED, PurchaseOrder::STATUS_CANCELLED]).paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    end
  end

end
