class InventoriesController < ApplicationController
  helper :supplies_manager
  
  # GET /inventories
  def index        
    @dates = Inventory.dates.paginate(:page => params[:page], :per_page => Inventory::DATES_PER_PAGE)
  end
  
  # GET /inventories/new?type=''
  def new
    @supply = params[:type].constantize.new
    @supplies_categories_root = (params[:type]+"Category").constantize.root
    @categories = (params[:type]+"Category").constantize.was_enabled_at
    @supplies = params[:type].constantize.was_enabled_at
  end
  
  # POST /inventories
  def create
    result = Inventory.create_stock_flows(params)
    if result == false
      @supply = params[:type].constantize.new
      @supplies_categories_root = (params[:type]+"Category").constantize.root
      @supplies = params[:type].constantize.was_enabled_at
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
    @supplies_categories_root = (params[:type]+"Category").constantize.root_including_inactives    
    @categories = (params[:type]+"Category").constantize.was_enabled_at(params[:date].to_date)
    @supplies = params[:type].constantize.was_enabled_at(params[:date].to_date)
    @date = params[:date].to_date
  end

end
