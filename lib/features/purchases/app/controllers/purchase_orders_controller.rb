class PurchaseOrdersController < ApplicationController
  
  helper :purchase_order_supplies, :purchase_request_supplies, :parcels, :parcel_items
  
  # GET /purchase_orders/
  def index
    redirect_to pending_purchase_orders_path
  end
  
  # GET /prepare_for_new
  # GET /prepare_for_new?page=:page
  # GET /prepare_for_new?choice=:choice
  # GET /prepare_for_new?choice=:choice&page=:page
  # GET /prepare_for_new?choice=:choice&supplier_id=:supplier_id
  # GET /prepare_for_new?choice=:choice&supplier_id=:supplier_id&page=:page
  def prepare_for_new
    @purchase_order = PurchaseOrder.new
    redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    unless params[:choice] or params[:supplier_id]
      @suppliers = PurchaseRequestSupply.all_suppliers_for_all_pending_purchase_request_supplies.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    end
  end
  
  # GET /purchase_orders/new
  # GET /purchase_orders/new?supplier_id=:supplier_id
  def new
    if params[:supplier_id] and (@supplier = Supplier.find(params[:supplier_id]))
      @purchase_order = PurchaseOrder.new(:supplier_id => @supplier.id)
      @purchase_order.build_with_purchase_request_supplies(@supplier.merge_purchase_request_supplies) if params[:from_purchase_request]
    elsif params[:supplier_id]
      redirect_to :action => :prepare_for_new, :choice => 1
    else
      redirect_to :action => :prepare_for_new
    end
  end
  
  # GET /purchase_orders/:purchase_order_id/edit
  def edit
    @purchase_order = PurchaseOrder.find(params[:id])
    error_access_page(412) unless @purchase_order.can_be_edited?
  end
  
  # PUT /purchase_orders/
  def create
    @purchase_order = PurchaseOrder.new(params[:purchase_order])
    @purchase_order.user_id = current_user.id
    if @purchase_order.save
      flash[:notice] = "L'ordre d'achat a été créé avec succès."
      redirect_to @purchase_order
    else
      render :action => "new"
    end
  end

  # PUT /purchase_orders/:purchase_order_id/
  def update
    if @purchase_order = PurchaseOrder.find(params[:id])
      if @purchase_order.update_attributes(params[:purchase_order])
        flash[:notice] = "L'ordre d'achat a été modifié avec succès"
        redirect_to @purchase_order
      else
        render :action => "edit"
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /auto_complete_for_supply_reference?supply[reference]=:supply[:reference]
  def auto_complete_for_supply_reference
    keywords = params[:supply][:reference].split(" ").collect(&:strip)
    @items = []
    @supplies = Supply.all
    keywords.each do |keyword|
      keyword = Regexp.new(keyword, Regexp::IGNORECASE)
      result = @supplies.select{|s| s.name =~ keyword or s.designation =~ keyword or s.reference =~ keyword}
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supply_reference_auto_complete', :object => @items, :locals => { :fields => "reference designation", :keywords => keywords }
  end
  
  # GET /auto_complete_for_supply_reference?supplier[name]=:supplier[:name]
  def auto_complete_for_supplier_name
    keywords = params[:supplier][:name].split(" ").collect(&:strip)
    @items = []
    keywords.each do |keyword|
      result = Supplier.all(:conditions => ["name LIKE ?", "%#{keyword}%"])
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supplier_name_auto_complete', :object => @items, :locals => { :fields => "name", :keywords => keywords }
  end
  
  # GET /purchase_order_supply_in_one_line?supply_id=:supply_id&supplier_id=:supplier_id
  def purchase_order_supply_in_one_line
    @supply = Supply.find(params[:supply_id])
    @supplier = Supplier.find(params[:supplier_id])
    @purchase_order_supply = PurchaseOrderSupply.new(:supply_id => @supply.id)
    render :partial => 'purchase_order_supplies/purchase_order_supply_in_one_line', :object => @purchase_order_supply,
                                                                                    :locals => {:supplier => @supplier}
  end
  
  # GET /purchase_orders/:purchase_order_id
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
  # GET /purchase_orders/:purchase_order_id/cancel
  def cancel
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_order.can_be_cancelled?
      @purchase_order.attributes = params[:purchase_order]
      @purchase_order.canceller = current_user
      if  @purchase_order.cancel
        flash[:notice] = "L'ordre d'achat a été annulé avec succès."
        redirect_to @purchase_order
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_order_id/cancel_form
  def cancel_form  
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_order.can_be_cancelled?
  end
  
  # DELETE /purchase_orders/:purchase_order_id
  def destroy
    if (@purchase_order = PurchaseOrder.find(params[:id])).can_be_deleted?
      unless @purchase_order.destroy
        flash[:error] = 'Une erreur est survenue lors de la suppression de l\'ordre d\'achat'
      end
      flash[:notice] = 'La suppression de l\'ordre d\'achat a été effectué avec succès'
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_order_id/confirm_form
  def confirm_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @purchase_order.can_be_confirmed? and @purchase_order.can_be_confirmed_with_purchase_request_supplies_associated? 
      if @purchase_order.can_be_edited?
        render :action => "edit"
      else
        error_access_page(412)
      end
    end
  end
    
  # GET /purchase_orders/:purchase_order_id/confirm  
  def confirm
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_order.can_be_confirmed?
      @purchase_order.attributes = params[:purchase_order]
      unless @purchase_order.confirm
        render :action => "confirm_form"
      else
        flash[:notice] = 'La confirmation de votre ordre d\'achat a été effectuée avec succès'
        redirect_to new_purchase_order_parcel_path(@purchase_order)
      end
    else
      error_access_page(412)
    end
  end
  
   # GET /purchase_orders/:purchase_order_id/cancel_supply/:purchase_order_supply_id
  def cancel_supply 
    @purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id]) 
    if @purchase_order_supply.can_be_cancelled?
      @purchase_order_supply.canceller = current_user
      if @purchase_order_supply.cancel 
        flash[:notice] = "La fourniture a été annuléé avec succès." 
      else
        flash[:error] = "une erreur est survenue lors de l'annulation de la fourniture." 
      end
      redirect_to @purchase_order_supply.purchase_order 
    else
      error_access_page(412)
    end
  end
  
   # GET /purchase_orders/:purchase_order_id/complete_form
  def complete_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    unless @purchase_order.can_be_completed?
      error_access_page(412)
    end
  end
  
   # GET /purchase_orders/:purchase_order_id/complete
  def complete
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_order.can_be_completed?
      @purchase_order.attributes = params[:purchase_order]
      unless @purchase_order.complete
        flash[:error] = "une erreur est survenue lors de la completion de l'ordre d'achat."
        render :action => "complete_form"
      else
        flash[:notice] = "L'ordre d'achat a été completé avec succès." 
        redirect_to @purchase_order
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_order_id/attached_invoice_document
  def attached_invoice_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    invoice_document = @purchase_order.invoice_document
    url = invoice_document.purchase_document.path
    
    send_data File.read(url), :filename => "#{@purchase_order.reference}_facture", :type => invoice_document.purchase_document_content_type, :disposition => 'attachment'
  end 
  
  # GET /purchase_orders/:purchase_order_id/attached_quotation_document
  def attached_quotation_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    quotation_document = @purchase_order.quotation_document
    url = quotation_document.purchase_document.path
    
    send_data File.read(url), :filename => "#{@purchase_order.reference}_devis", :type => quotation_document.purchase_document_content_type, :disposition => 'attachment'
  end 
  
end
