class PurchaseOrdersSupplyController < ApplicationController
  def cancel_form
    @purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id])
    unless can_be_cancelled?
      error_access_page(412)
    end
  end
  
  def cancel
    if (@purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id])).can_be_cancelled?
      if @purchase_order_supply.cancel(@purchase_order_supply)
        flash[:notice] = 'La commande de cette fourniture a bien été annulée'
      end
      redirect_to @purchase_order_supply.purchase_order
    else
      error_access_page(412)
    end
  end
  
  def destroy
    if (@purchase_order_supply = PurchaseOrderSupply.find(params[:id])).can_be_deleted?
      if @purchase_order_supply.destroy
        flash[:notice] = 'Une erreur est survenue lors la suppression de la fourniture commandée'
      end
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
end
