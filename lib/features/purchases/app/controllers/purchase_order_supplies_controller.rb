class PurchaseOrderSuppliesController < ApplicationController
  
  # GET /purchase_orders/:purchase_order_id/purchase_order_supplies/:purchase_order_supply_id/cancel_form
  def cancel_form
    @purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id])
    error_access_page(412) unless @purchase_order_supply.can_be_cancelled?
  end
  
  # GET /purchase_orders/:purchase_order_id/purchase_order_supplies/:purchase_order_supply_id/cancel
  def cancel
    if (@purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id])).can_be_cancelled?
      @purchase_order_supply.cancelled_comment = params[:purchase_order_supply][:cancelled_comment]
      @purchase_order_supply.cancelled_by = current_user.id
      flash[:notice] = 'La commande de cette fourniture a bien été annulée' if @purchase_order_supply.cancel
      redirect_to @purchase_order_supply.purchase_order
    else
      error_access_page(412)
    end
  end
end
