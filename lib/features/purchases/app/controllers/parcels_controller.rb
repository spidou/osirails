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
    if params[:parcel][:status] == ""
      redirect_to purchase_order_parcel_process_by_supplier_path(@purchase_order, @parcel)
    elsif params[:parcel][:status] == Parcel::STATUS_SHIPPED
      redirect_to purchase_order_parcel_ship_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status] == Parcel::STATUS_RECEIVED_BY_FORWARDER
      redirect_to purchase_order_parcel_receive_by_forwarder_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status] == Parcel::STATUS_RECEIVED
      redirect_to purchase_order_parcel_receive_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status] == Parcel::STATUS_CANCELLED
      @parcel.cancelled_by = current_user.id
      redirect_to purchase_order_parcel_cancel_form_path(@purchase_order, @parcel)
    else
      redirect_to purchase_order_path(@purchase_order)
    end
  end
  
  def process_by_supplier_form
    @parcel = Parcel.find(params[:parcel_id])
  end
  
  def process_by_supplier
    @parcel = Parcel.find(params[:parcel_id])
    if @parcel.can_be_processing_by_supplier?
      if @parcel.process_by_supplier
        flash[:notice] = "Le status du colis est bien passé à \"En traitement par le fournisseur\"."
        redirect_to @purchase_order
      else
        render :action => "process_by_supplier_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def ship_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @parcel.can_be_shipped?
      error_access_page(412)
    end
  end
  
  def ship
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_shipped?
      if  @parcel.ship(params[:parcel])
        flash[:notice] = "Le status du colis est bien passé à \"Expédié\"."
        redirect_to @purchase_order
      else
        render :action => "ship_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def receive_by_forwarder_form
      @parcel = Parcel.find(params[:parcel_id])
      @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @parcel.can_be_received_by_forwarder?
      error_access_page(412)
    end
  end
  
  def receive_by_forwarder
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_received_by_forwarder?
      if  @parcel.receive_by_forwarder(params[:parcel])
        flash[:notice] = "Le status du colis est bien passé à \"Reçu par le transitaire\"."
        redirect_to @purchase_order
      else
        render :action => "receive_by_forwarder_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def receive_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @parcel.can_be_received?
      error_access_page(412)
    end
  end
  
  def receive
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_received?
      if  @parcel.receive(params[:parcel])
        flash[:notice] = "Le status du colis est bien passé à \"Reçu\"."
        redirect_to @purchase_order
      else
        render :action => "receive_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def cancel_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @parcel.can_be_cancelled?
      error_access_page(412)
    end
  end
  
  def get_parcel_status_partial
    render :partial => 'parcels/receive_forms' if params[:status] == Parcel::STATUS_RECEIVED
    render :partial => 'parcels/ship_forms' if params[:status] == Parcel::STATUS_SHIPPED
    render :partial => 'parcels/receive_by_forwarder_forms' if params[:status] == Parcel::STATUS_RECEIVED_BY_FORWARDER
    render :text => '' if params[:status] == ""
  end
  
  def cancel
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_cancelled?
      if  @parcel.cancel(params[:parcel])
        flash[:notice] = "Le colis a été annulé avec succès."
        redirect_to @purchase_order
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
end
