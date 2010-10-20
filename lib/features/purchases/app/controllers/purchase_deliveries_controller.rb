class PurchaseDeliveriesController < ApplicationController

  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :purchase_delivery_items
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/new
  def new 
    @purchase_delivery = PurchaseDelivery.new()
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  def create
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.new(params[:purchase_delivery])
    if @purchase_delivery.save
      flash[:notice] = "Le colis a été créé avec succès."
      redirect_to @purchase_order
    else
      render :action => "new"
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id
  def show
    @purchase_delivery = PurchaseDelivery.find(params[:id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/alter_status
  def alter_status
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if params[:purchase_delivery][:status].to_i == PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER
      redirect_to purchase_order_purchase_delivery_process_by_supplier_form_path(@purchase_order, @purchase_delivery)
    elsif params[:purchase_delivery][:status].to_i == PurchaseDelivery::STATUS_SHIPPED
      redirect_to purchase_order_purchase_delivery_ship_form_path(@purchase_order, @purchase_delivery)
    elsif params[:purchase_delivery][:status].to_i == PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER
      redirect_to purchase_order_purchase_delivery_receive_by_forwarder_form_path(@purchase_order, @purchase_delivery)
    elsif params[:purchase_delivery][:status].to_i == PurchaseDelivery::STATUS_RECEIVED
      redirect_to purchase_order_purchase_delivery_receive_form_path(@purchase_order, @purchase_delivery)
    elsif params[:purchase_delivery][:status].to_i == PurchaseDelivery::STATUS_CANCELLED
      @purchase_delivery.canceller = current_user
      redirect_to purchase_order_purchase_delivery_cancel_form_path(@purchase_order, @purchase_delivery)
    else
      redirect_to purchase_order_path(@purchase_order)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/process_by_supplier_form
  def process_by_supplier_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    error_access_page(412) unless @purchase_delivery.can_be_processed_by_supplier? 
    @purchase_delivery.status = PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/process_by_supplier
  def process_by_supplier
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_delivery.can_be_processed_by_supplier?
      @purchase_delivery.attributes = params[:purchase_delivery]
      if @purchase_delivery.process_by_supplier
        flash[:notice] = "Le status du colis est bien passé à \"En traitement par le fournisseur\"."
        redirect_to @purchase_order
      else
        render :action => "process_by_supplier_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/ship_form
  def ship_form
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_delivery.can_be_shipped?
    @purchase_delivery.status = PurchaseDelivery::STATUS_SHIPPED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/ship
  def ship
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_delivery.can_be_shipped?
      @purchase_delivery.attributes = params[:purchase_delivery]
      if @purchase_delivery.ship
        flash[:notice] = "Le status du colis est bien passé à \"Expédié\"."
        redirect_to @purchase_order
      else
        render :action => "ship_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/receive_by_forwarder_form
  def receive_by_forwarder_form
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_delivery.can_be_received_by_forwarder?
    @purchase_delivery.status = PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end

  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/receive_by_forwarder  
  def receive_by_forwarder
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_delivery.can_be_received_by_forwarder?
      @purchase_delivery.attributes = params[:purchase_delivery]
      if @purchase_delivery.receive_by_forwarder
        flash[:notice] = "Le status du colis est bien passé à \"Reçu par le transitaire\"."
        redirect_to @purchase_order
      else
        render :action => "receive_by_forwarder_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/receive_form
  def receive_form
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_delivery.can_be_received?
    @purchase_delivery.status = PurchaseDelivery::STATUS_RECEIVED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end

  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/receive  
  def receive
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_delivery.can_be_received?
      @purchase_delivery.attributes = params[:purchase_delivery]
      if @purchase_delivery.receive
        flash[:notice] = "Le status du colis est bien passé à \"Reçu\"."
        redirect_to @purchase_order
      else
        render :action => "receive_form"   
      end
    else
      error_access_page(412)
    end
  end

  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/cancel_form
  def cancel_form
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_delivery.can_be_cancelled?
    @purchase_delivery.status = PurchaseDelivery::STATUS_CANCELLED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/cancel
  def cancel
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_delivery.can_be_cancelled?
      @purchase_delivery.attributes = params[:purchase_delivery]
      @purchase_delivery.canceller = current_user
      if @purchase_delivery.cancel
        flash[:notice] = "Le colis a été annulé avec succès."
        redirect_to @purchase_order
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end

  # GET /purchase_delivery_status_partial?status=:status 
  def purchase_delivery_status_partial
    render :partial => 'purchase_deliveries/receive_forms' if params[:status].to_i == PurchaseDelivery::STATUS_RECEIVED
    render :partial => 'purchase_deliveries/ship_forms' if params[:status].to_i == PurchaseDelivery::STATUS_SHIPPED
    render :partial => 'purchase_deliveries/receive_by_forwarder_forms' if params[:status].to_i == PurchaseDelivery::STATUS_RECEIVED_BY_FORWARDER
    render :partial => 'purchase_deliveries/process_by_supplier_forms' if params[:status].to_i == PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER
  end
  
  # GET /purchase_orders/:purchase_orders_id/purchase_deliveries/:purchase_delivery_id/attached_delivery_document
  def attached_delivery_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_delivery = PurchaseDelivery.find(params[:purchase_delivery_id])
    delivery_document =  @purchase_delivery.delivery_document
    url = delivery_document.purchase_document.path
   
    send_data File.read(url), :filename => "purchase_delivery_delivery.#{delivery_document.id}_#{delivery_document.purchase_document_file_name}", :type => delivery_document.purchase_document_content_type, :disposition => 'purchase_delivery_delivery'
  end 
  
end
