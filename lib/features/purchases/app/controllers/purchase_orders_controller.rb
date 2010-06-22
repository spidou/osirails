class PurchaseOrdersController < ApplicationController
  
  def index
    @purchase_orders = PurchaseOrder.all
  end
  
  def prepare_for_new
   @purchase_order = PurchaseOrder.new
    if params[:supplier_id]
      redirect_to :action => :new, :supplier_id => params[:supplier_id]
    end
    @purchase_requests = PurchaseRequest.all unless params[:choice] or params[:supplier_id]  
    @suppliers = PurchaseRequestSupply.get_all_suppliers_for_all_purchase_request_supplies unless params[:choice] or params[:supplier_id]
  end
  
  def new
    if !params[:supplier_id]
      redirect_to :action => :prepare_for_new
    else
      @purchase_order = PurchaseOrder.new
      @supplier = Supplier.find(params[:supplier_id])
      @purchase_order.supplier_id = params[:supplier_id]
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
   
end
