class InventoriesController < ApplicationController
  helper :supplies_manager
  
  # GET /inventories
  def index        
    @dates = Inventory.dates
  end
  
  # GET /inventories/new?type=''
  def new
    @supply = params[:type].constantize.new
    @supplies_categories_root = (params[:type]+"Category").constantize.root
    @supplies_categories_root_child = (params[:type]+"Category").constantize.root_child
    @supplies = params[:type].constantize.activates
  end
  
  # POST /inventories
  def create
    result = Inventory.create_stock_flows(params)
    if result == false
      @supply = params[:type].constantize.new
      @supplies_categories_root = (params[:type]+"Category").constantize.root
      @supplies_categories_root_child = (params[:type]+"Category").constantize.root_child
      @supplies = params[:type].constantize.activates
      flash[:error] = "Les données rentrées sont invalides"
      render :action => 'new'
    else
      flash[:error] = "Aucune évolution de stock n'a été trouvée" if result == 0
      flash[:notice] = "L'inventaire a été enregistré et #{result} ajustements de stock ont été effectués" if result > 0
      flash[:notice] = "L'inventaire a été enregistré et un ajustement de stock a été effectué" if result == 1
      redirect_to :action => 'index'
    end
  end
  
  # GET /inventories/show?date=''&type=''
  def show
    @supply = params[:type].constantize.new
    @supplies_categories_root = (params[:type]+"Category").constantize.root
    @supplies_categories_root_child = (params[:type]+"Category").constantize.root_child
    @supplies = params[:type].constantize.activates
    @date = params[:date].to_date
  end

end
