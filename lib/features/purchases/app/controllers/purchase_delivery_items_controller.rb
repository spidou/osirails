class PurchaseDeliveryItemsController < ApplicationController
  
  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :purchase_deliveries
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/purchase_delivery_items/:purchase_delivery_item_id/cancel_form
  def cancel_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_delivery_item = PurchaseDeliveryItem.find(params[:purchase_delivery_item_id])
    unless @purchase_delivery_item.can_be_cancelled?
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/purchase_delivery_items/:purchase_delivery_item_id/cancel 
  def cancel
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_delivery_item = PurchaseDeliveryItem.find(params[:purchase_delivery_item_id])
    if @purchase_delivery_item.can_be_cancelled?
      @purchase_delivery_item.attributes = params[:purchase_delivery_item]
      @purchase_delivery_item.canceller = current_user
      if @purchase_delivery_item.cancel
        flash[:notice] = "Le contenu correspondant a été annulé."
        redirect_to( purchase_order_purchase_delivery_path(@purchase_delivery_item.purchase_order_supply.purchase_order, @purchase_delivery_item.purchase_delivery))
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/purchase_delivery_items/:purchase_delivery_item_id/report_form
  def report_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_delivery_item = PurchaseDeliveryItem.find(params[:purchase_delivery_item_id])
    unless @purchase_delivery_item.can_be_reported?
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/purchase_delivery_items/:purchase_delivery_item_id/report
  def report
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_delivery_item = PurchaseDeliveryItem.find(params[:purchase_delivery_item_id])
    if @purchase_delivery_item.can_be_reported?
      @purchase_delivery_item.attributes = params[:purchase_delivery_item]
      if @purchase_delivery_item.report
        flash[:notice] = "Le contenu correspondant a été signalé comme défectueux."
        redirect_to( purchase_order_path(@purchase_delivery_item.purchase_order_supply.purchase_order))
      else
        render :action => "report_form"   
      end
    else
      error_access_page(412)
    end
  end
  
end
