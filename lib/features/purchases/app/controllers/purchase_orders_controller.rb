class PurchaseOrdersController < ApplicationController
  
  helper :purchase_order_supplies, :parcels, :parcel_items
  
  def index
    redirect_to pending_purchase_orders_path
  end
  
  def prepare_for_new
    @purchase_order = PurchaseOrder.new
    redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    unless params[:choice] or params[:supplier_id]
      @suppliers = PurchaseRequestSupply.get_all_suppliers_for_all_purchase_request_supplies.paginate(:page => params[:page], :per_page => PurchaseOrder::REQUESTS_PER_PAGE)
    end
  end
  
  def new
    if !params[:supplier_id]
      redirect_to :action => :prepare_for_new
    else 
      @purchase_order = PurchaseOrder.new
      @supplier = Supplier.find(params[:supplier_id])
      @purchase_order.supplier_id = params[:supplier_id]
      @list_of_supplies = @supplier.merge_purchase_request_supplies if params[:from_purchase_request]
      @purchase_order.build_with_purchase_request_supplies(@list_of_supplies) if params[:from_purchase_request] 
    end
  end
  
  def edit
    @purchase_order  = PurchaseOrder.find(params[:id])
    error_access_page(412) unless @purchase_order.can_be_edited?
  end
  
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
  
  def update
    if @purchase_order = PurchaseOrder.find(params[:id])
      if @purchase_order.update_attributes(params[:purchase_order])
        flash[:notice] = "L'ordre d'achats a été modifié avec succès"
        redirect_to @purchase_order
      else
        render :action => "edit"
      end
    else
      error_access_page(412)
    end
  end
  
  def auto_complete_for_supply_reference
    keywords = params[:supply][:reference].split(" ").collect(&:strip)
    @items = []
    @supplies = Supply.all()
    keywords.each do |keyword|
      keyword = Regexp.new(keyword, Regexp::IGNORECASE)
      result = @supplies.select{|s| s.name =~ keyword or s.designation =~ keyword or s.reference =~ keyword}
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supply_reference_auto_complete', :object => @items, :locals => { :fields => "reference designation", :keywords => keywords }
  end
  
  def auto_complete_for_supplier_name
    keywords = params[:supplier][:name].split(" ").collect(&:strip)
    @items = []
    keywords.each do |keyword|
      result = Supplier.all(:conditions => ["name LIKE ?", "%#{keyword}%"])
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supplier_name_auto_complete', :object => @items, :locals => { :fields => "name", :keywords => keywords }
  end
  
  def get_purchase_order_supply_in_one_line
    @supply = Supply.find(params[:supply_id])
    @supplier = Supplier.find(params[:supplier_id])
    @purchase_order_supply = PurchaseOrderSupply.new
    @purchase_order_supply.supply_id = params[:supply_id]
    render :partial => 'purchase_order_supplies/purchase_order_supply_in_one_line',
                                                 :object  => @purchase_order_supply,
                                                 :locals => {:supplier => @supplier}
  end
  
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
  def cancel
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @purchase_order.can_be_cancelled?
      @purchase_order.attributes = params[:purchase_order]
      @purchase_order.cancelled_by = current_user.id
      if  @purchase_order.cancel
        flash[:notice] = "L'ordre d'achats a été annulé avec succès."
        redirect_to @purchase_order
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def cancel_form  
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @purchase_order.can_be_cancelled?
  end
  
  def destroy
    if (@purchase_order = PurchaseOrder.find(params[:id])).can_be_deleted?
      unless @purchase_order.destroy
        flash[:error] = 'Une erreur est survenue lors de la suppression de l\'ordre d\'achats'
      end
      flash[:notice] = 'La suppression de l\'ordre d\'achats a été effectué avec succès'
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
  
  def confirm_form
    unless (@purchase_order = PurchaseOrder.find(params[:purchase_order_id])).can_be_confirmed?
      error_access_page(412)
    end
  end
    
  def confirm
    if (@purchase_order = PurchaseOrder.find(params[:purchase_order_id])).can_be_confirmed?
      @purchase_order.attributes = params[:purchase_order]
      unless @purchase_order.confirm
        render :action => "confirm_form"
      else
        redirect_to purchase_orders_path
      end
    else
      error_access_page(412)
    end
  end
  
  def cancel_supply 
    @purchase_order_supply = PurchaseOrderSupply.find(params[:purchase_order_supply_id]) 
    if @purchase_order_supply.can_be_cancelled?
      @purchase_order_supply.cancelled_by = current_user.id
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
  
  def complete_form
    unless (@purchase_order = PurchaseOrder.find(params[:purchase_order_id])).can_be_completed?
      error_access_page(412)
    end
  end
  
  def complete
    if (@purchase_order = PurchaseOrder.find(params[:purchase_order_id])).can_be_completed?
      @purchase_order.attributes = params[:purchase_order]
      unless @purchase_order.complete
        flash[:error] = "une erreur est survenue lors de la completion de l'ordre d'achat."
        render :action => "complete_form"
      else
        flash[:notice] = "L'ordre d'achat a été completé avec succès." 
        redirect_to closed_purchase_orders_path
      end
    else
      error_access_page(412)
    end
  end
  
  def attached_invoice_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    invoice_document =  @purchase_order.invoice_document
    url = invoice_document.purchase_document.path
    
    send_data File.read(url), :filename => "purchase_order_invoice.#{invoice_document.id}_#{invoice_document.purchase_document_file_name}", :type => invoice_document.purchase_document_content_type, :disposition => 'purchase_document_invoice'
  end 
  
  def attached_quotation_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    quotation_document =  @purchase_order.quotation_document
    url = quotation_document.purchase_document.path
    
    send_data File.read(url), :filename => "purchase_order_quotation.#{quotation_document.id}_#{quotation_document.purchase_document_file_name}", :type => quotation_document.purchase_document_content_type, :disposition => 'purchase_document_quotation'
  end 
  
end
