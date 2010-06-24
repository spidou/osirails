class PurchaseOrdersController < ApplicationController
  
  def index
    redirect_to pending_purchase_orders_path
  end
  
  def prepare_for_new
   @purchase_order = PurchaseOrder.new
    redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    unless params[:choice] or params[:supplier_id] 
      @purchase_requests = PurchaseRequest.all
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
  
  def create
    @purchase_order = PurchaseOrder.new(params[:purchase_order])
    @purchase_order.user_id = current_user.id
    if @purchase_order.save
      flash[:notice] = "L'ordre d'achat a été créé(e) avec succès."
      redirect_to @purchase_order
    else
      render :action => "new"
    end
  end
  
  def update_table
    render :partial => ""
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
  
  def recup_supply
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
    
  end
  
  def destroy
    if (@purchase_order = PurchaseOrder.find(params[:id])).can_be_deleted?
      unless @purchase_order.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression de l\'ordre d\'achats;'
      end
      redirect_to purchase_orders_path
    else
      error_access_page(412)
    end
  end
end
