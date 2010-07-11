class ParcelsController < ApplicationController

  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :parcel_items
  
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
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if params[:parcel][:status] == Parcel::STATUS_PROCESSING
      redirect_to purchase_order_parcel_process_form_path(params[:parcel_id])
    elsif params[:parcel][:status] == Parcel::STATUS_SHIPPED
      redirect_to purchase_order_parcel_ship_form_path(params[:purchase_order_id], params[:parcel_id])
    elsif params[:parcel][:status] == Parcel::STATUS_RECEIVED_BY_FORWARDER
      redirect_to purchase_order_parcel_receive_by_forwarder_form__path(params[:parcel_id])
    elsif params[:parcel][:status] == Parcel::STATUS_RECEIVED
      redirect_to purchase_order_parcel_receive_form_path(params[:parcel_id])
    elsif params[:parcel][:status] == Parcel::STATUS_CANCEL
      redirect_to purchase_order_parcel_cancel_form_path(params[:parcel_id])
    else
      redirect_to purchase_order_path(@purchase_order)
    end
  end
  
  def process_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
#  def process
#    @parcel = Parcel.find(params[:parcel_id])
#    if @parcel.can_be_processing?
#      if  @parcel.process
#        flash[:notice] = "Le status du colis est bien passé à \"En traitement\"."
#        redirect_to @parcel
#      else
#        render :action => "process_form"   
#      end
#    else
#      error_access_page(412)
#    end
#  end
#  
  def ship_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
  def ship
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_shipped?
      @parcel.shipped_at = params[:parcel][:shipped_at]
      @parcel.conveyance = params[:parcel][:conveyance]
      @parcel.previsional_delivery_date = params[:parcel][:previsional_delivery_date]
      if  @parcel.ship
        flash[:notice] = "Le status du colis est bien passé à \"Expédié\"."
        redirect_to(@purchase_order, @parcel)
      else
        render :action => "ship_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def receive_by_forwarder_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
  def receive_by_forwarder
    @parcel = Parcel.find(params[:parcel_id])
    if @parcel.can_be_received_by_forwarder?
      @parcel.received_by_forwarder_at = params[:parcel][:received_by_forwarder_at]
      @parcel.awaiting_pick_up = params[:parcel][:awaiting_pick_up]
      if  @parcel.ship
        flash[:notice] = "Le status du colis est bien passé à \"Reçu par le transitaire\"."
        redirect_to @parcel
      else
        render :action => "receive_by_forwarder_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def receive_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
  def receive
    @parcel = Parcel.find(params[:parcel_id])
    if @parcel.can_be_received?
      @parcel.shipped_at = params[:parcel][:shipped_at]
      @parcel.conveyance = params[:parcel][:conveyance]
      @parcel.previsional_delivery_date = params[:parcel][:previsional_delivery_date]
      @parcel.received_by_forwarder_at = params[:parcel][:received_by_forwarder_at]
      @parcel.awaiting_pick_up = params[:parcel][:awaiting_pick_up]
      if  @parcel.receive
        flash[:notice] = "Le status du colis est bien passé à \"Reçu\"."
        redirect_to @parcel
      else
        render :action => "receive_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def cancel_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
  def cancel
    @parcel = Parcel.find(params[:parcel_id])
    if @parcel.can_be_cancelled?
      @parcel.cancelled_by = current_user.id
      @parcel.cancelled_comment  = params[:parcel][:cancelled_comment]
      if  @purchase_order.cancel
        flash[:notice] = "Le colis a été annulé avec succès."
        redirect_to @parcel
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
end
