class ParcelsController < ApplicationController

  helper :purchase_requests, :purchase_orders
  
  def new 
    @parcel = Parcel.new()
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  def create
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.new(params[:parcel])
    if @parcel.save
      flash[:notice] = "Le colis a été créé avec succès."
      redirect_to @purchase_order
    else
      render :action => "new"
    end
  end
  
  def alter_status
    @parcel = Parcel.find(params[:parcel_id])
    if params[:status] == Parcel::STATUS_PROCESSING
      redirect_to purchase_order_process_parcel_path(params[:parcel_id])
    elsif params[:status] == Parcel::STATUS_SHIPPED
      redirect_to purchase_order_ship_parcel_path(params[:parcel_id])
    elsif params[:status] == Parcel::STATUS_RECEIVED_BY_FORWARDER
      redirect_to purchase_order_receive_by_forwarder_path(params[:parcel_id])
    elsif params[:status] == Parcel::STATUS_RECEIVED
      redirect_to purchase_order_receive_path(params[:parcel_id])
    else
      redirect_to purchase_order_path(@parcel.parcel_items.first.purchase_order_supply.purchase_order)
    end
  end
end
