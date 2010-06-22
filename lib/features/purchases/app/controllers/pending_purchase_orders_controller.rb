class PendingPurchaseOrdersController < ApplicationController
  
  helper :purchase_orders
  
  def index
    @pending_purchase_orders = PurchaseOrder.all(:conditions => ["(status is null) or (status = ?) or (status = ?)", PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING])
  end

end
