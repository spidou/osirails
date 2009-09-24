class StockInputsController < ApplicationController
  helper :stock_flows

  # GET /stock_inputs/index
  def index
    @commodities_stock_flows = StockInput.commodities_stock_inputs.paginate(:page => params[:page], :order => "created_at DESC", :per_page => StockFlow::STOCK_FLOWS_PER_PAGE)
    @consumables_stock_flows = StockInput.consumables_stock_inputs.paginate(:page => params[:page], :order => "created_at DESC", :per_page => StockFlow::STOCK_FLOWS_PER_PAGE)
  end

  # GET /stock_inputs/new
  def new
    @supply = params[:supply_id].nil? ? params[:type].constantize.find(:first) : Supply.find(params[:supply_id])
    @supplier = params[:supplier_id].nil? ? @supply.suppliers.first : Supplier.find(params[:supplier_id])
    @supplies = params[:type].nil? ? @supply[:type].constantize.was_enabled_at : params[:type].constantize.was_enabled_at
    @suppliers = @supply.suppliers
    @supplier_supply = SupplierSupply.find_by_supply_id_and_supplier_id(@supply.id,@supplier.id)
    @stock_flow = StockInput.new({:fob_unit_price => @supplier_supply.fob_unit_price,
                                  :tax_coefficient => @supplier_supply.tax_coefficient})
    @stock_flow = StockInput.new({:supply_id => @supply.id,
                                  :supplier_id => @supplier.id,
                                  :fob_unit_price => @supplier_supply.fob_unit_price,
                                  :tax_coefficient => @supplier_supply.tax_coefficient
                                 }) unless params[:supply_id].nil? and params[:supplier_id].nil?
  end

  # POST /stock_inputs
  def create
    @stock_flow = StockInput.new(params[:stock_input])
    if @stock_flow.save
      flash[:notice] = "L'entrée de stock a été effectuée avec succès"
      redirect_to :action => 'index'
    else
      @supply = Supply.find(@stock_flow.supply_id)
      @supplier = Supplier.find(@stock_flow.supplier_id)
      @supplies = @supply[:type].constantize.was_enabled_at
      @suppliers = @supply.suppliers
      render :action => 'new'
    end
  end
end

