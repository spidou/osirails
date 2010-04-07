class StockOutputsController < ApplicationController
  helper :stock_flows

  # GET /stock_outputs/index
  def index
    @commodities_stock_flows = StockOutput.commodities_stock_outputs.paginate(:page => params[:page], :order => "created_at DESC", :per_page => StockFlow::STOCK_FLOWS_PER_PAGE)
    @consumables_stock_flows = StockOutput.consumables_stock_outputs.paginate(:page => params[:page], :order => "created_at DESC", :per_page => StockFlow::STOCK_FLOWS_PER_PAGE)
  end

  # GET /stock_outputs/new
  def new
    return error_access_page(500) unless ["Commodity","Consumable",nil].include?(params[:type])
    @supply_type = params[:type].constantize unless params[:type].nil?
    
    @supply = params[:supply_id].nil? ? @supply_type.find(:first) : Supply.find(params[:supply_id])
    @supplier = params[:supplier_id].nil? ? @supply.suppliers.first : Supplier.find(params[:supplier_id])
    @supplies = params[:type].nil? ? @supply[:type].constantize.was_enabled_at : @supply_type.was_enabled_at
    @suppliers = @supply.suppliers
    @supplier_supply = SupplierSupply.find_by_supply_id_and_supplier_id(@supply.id,@supplier.id)
    @stock_flow = StockOutput.new
    @stock_flow = StockOutput.new({:supply_id => @supply.id,
                                   :supplier_id => @supplier.id
                                  }) unless params[:supply_id].nil? and params[:supplier_id].nil?
  end

  # POST /stock_outputs
  def create
    @stock_flow = StockOutput.new(params[:stock_output])
    if @stock_flow.save
      flash[:notice] = "La sortie de stock a été effectuée avec succès"
      redirect_to :action => 'index'
    else
      @supply = Supply.find(@stock_flow.supply_id)
      @supplies = @supply[:type].constantize.find(:all)
      @suppliers = @supply.suppliers
      render :action => 'new'
    end
  end
end

