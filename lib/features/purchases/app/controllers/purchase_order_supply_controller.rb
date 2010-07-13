class PurchaseOrdersSupplyController < ApplicationController
  def destroy
    if (@purchase_order_supply = PurchaseOrderSupply.find(params[:id])).can_be_deleted?
      unless @purchase_order_supply.destroy
        flash[:notice] = 'Une erreur est survenue lors la suppression de la fourniture commandée'
      end
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
end
