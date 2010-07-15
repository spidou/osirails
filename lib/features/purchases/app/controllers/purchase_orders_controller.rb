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
  
  def update_table
    render :partial => ""
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
      result = Supplier.all(:conditions => ["name LIKE ?", "%"+keyword+"%"])
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supplier_name_auto_complete', :object => @items, :locals => { :fields => "name", :keywords => keywords }
  end
  
  def get_supply
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
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
  
  def confirm
    if (@purchase_order = PurchaseOrder.find(params[:purchase_order_id])).can_be_confirmed?
      unless @purchase_order.confirm
        if @purchase_order.can_be_edited?
          render :action => "edit"
        else
          error_access_page(412)
        end
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
        flash[:error] = "une erreur est survenue lors de l'annullation de la fourniture." 
      end
      redirect_to @purchase_order_supply.purchase_order 
    else
      error_access_page(412)
    end
  end
  
end
