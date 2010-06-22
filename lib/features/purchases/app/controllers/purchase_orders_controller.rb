class PurchaseOrdersController < ApplicationController

  def index
    redirect_to pending_purchase_orders_path
  end
  
  def new
    @purchase_order = PurchaseOrder.new
    @purchase_requests = PurchaseRequest.all
    @suppliers = PurchaseRequestSupply.get_all_suppliers_for_all_purchase_request_supplies.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
  end
  
  def update_table
    render :partial => ""
  end
  
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
  def cancel
    
  end
  
  def destroy
    if (@purchase_order = PurchaseOrder.find(params[:id])).can_be_deleted?
      unless @purchase_order.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression de l\'ordre d\'achats;'
      end
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
end
