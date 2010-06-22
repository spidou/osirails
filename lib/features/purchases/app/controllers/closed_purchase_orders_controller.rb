class ClosedPurchaseOrdersController < ApplicationController

  helper :purchase_orders, :parcels
  
  def index
    @closed_purchase_orders = PurchaseOrder.all(:conditions => ["status = ?", PurchaseOrder::STATUS_COMPLETED])
    if params['filter'] == PurchaseOrder::STATUS_CANCELLED
      @closed_purchase_orders = PurchaseOrder.all(:conditions => ["status = ?", PurchaseOrder::STATUS_CANCELLED])
    end
  end

end
