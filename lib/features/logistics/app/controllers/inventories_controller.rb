class InventoriesController < ApplicationController
  helper :supplies_manager
  before_filter :supply_type, :except => [:index]
  before_filter :supply_category_type, :except => [:index]
  
  # GET /inventories
  def index        
    @dates = Inventory.dates.paginate(:page => params[:page], :per_page => Inventory::DATES_PER_PAGE)
  end
  
  # GET /inventories/new?type=''
  def new
    @date = Date.today
    @supply_categories_root = @supply_category_type.enabled_roots
    @supplies = @supply_type.was_enabled_at
  end
  
  # POST /inventories
  def create
    result = Inventory.create_stock_flows(params)
    if result == false
      @supply_categories_root = @supply_category_type.enabled_roots
      @supplies = @supply_type.was_enabled_at
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
    begin
      @date = params[:date].to_date
      @supply_categories_root = @supply_category_type.roots  
      @supplies = @supply_type.was_enabled_at(@date)
    rescue ArgumentError => e
      error_access_page(500)
    end
  end

  private
    def supply_type
      if ["Commodity","Consumable"].include?(params[:type])
        @supply_type = params[:type].constantize
      else
        error_access_page(500)
      end
    end
    
    def supply_category_type
      if ["Commodity","Consumable"].include?(params[:type])
        @supply_category_type = (params[:type]+"Category").constantize
      else
        error_access_page(500)
      end
    end
end
