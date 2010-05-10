class InventoriesController < ApplicationController
  helper :supplies_manager
  
  before_filter :find_inventory,                              :only   => :show
  before_filter :define_supply_type_and_supply_category_type, :except => :index
  before_filter :define_date,                                 :except => :index
  before_filter :find_supply_categories,                      :except => :index
  before_filter :find_supplies,                               :except => :index
  
#  before_filter :supply_category_type, :except => [:index]
  
  # GET /inventories
  def index        
    @inventories = Inventory.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => Inventory::INVENTORIES_PER_PAGE)
  end
  
  # GET /inventories/new?supply_type=:supply_type
  def new
    @inventory = Inventory.new(:supply_type => params[:supply_type])
  end
  
  # POST /inventories
  def create
    attributes = { :supply_type => params[:supply_type] }.merge(params[:inventory])
    @inventory = Inventory.new(attributes)
    
    if @inventory.save
      flash[:notice] = "L'inventaire a été créé avec succès"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  # GET /inventories/:id
  def show
  end

  private
    def find_inventory
      @inventory = Inventory.find(params[:id])
    end
    
    def define_supply_type_and_supply_category_type
      if ["Commodity","Consumable"].include?(params[:supply_type])
        @supply_type          = params[:supply_type].constantize
        @supply_category_type = "#{params[:supply_type]}Category".constantize
      elsif @inventory
        @supply_type          = @inventory.supply_type.constantize
        @supply_category_type = "#{@inventory.supply_type}Category".constantize
      else
        error_access_page(500)
      end
    end
    
    def define_date
      if params[:date]
        begin
          @date = params[:date].to_datetime
        rescue
          return error_access_page(400)
        end
      elsif @inventory
        @date = @inventory.date
      else
        @date = Time.zone.now
      end
    end
    
    def find_supply_categories
      if [:new, :create].include?(params[:action])
        @supply_categories = @supply_category_type.enabled
      else
        @supply_categories = @supply_category_type.all
      end
    end
    
    def find_supplies
      @supplies = @supply_type.was_enabled_at(@date)
    end
end
