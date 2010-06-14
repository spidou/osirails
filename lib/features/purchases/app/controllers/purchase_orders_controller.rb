class PurchaseOrdersController < ApplicationController

  def index
    @purchase_orders = PurchaseOrder.all
  end
  
  def new
    @purchase_order = PurchaseOrder.new
    @purchase_requests = PurchaseRequest.all

    @suppliers = PurchaseRequestSupply.get_all_suppliers_for_all_purchase_request_supplies
  end
  
  def update_table
    render :partial => ""
  end
end
