class InventoriesController < ApplicationController
  helper :supplies_manager
  
  before_filter :find_inventory,      :only   => :show
  before_filter :define_supply_class, :except => :index
  before_filter :define_date,         :except => :index
  before_filter :find_supplies,       :except => :index
  
  # GET /inventories
  def index
    @inventories = Inventory.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => Inventory::INVENTORIES_PER_PAGE)
  end
  
  # GET /inventories/new?supply_class=:supply_class
  def new
    @inventory = Inventory.new(:supply_class => params[:supply_class])
  end
  
  # POST /inventories
  def create
    attributes = { :supply_class => params[:supply_class] }.merge(params[:inventory])
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
    
    def define_supply_class
      if ["Commodity","Consumable"].include?(params[:supply_class])
        @supply_class = params[:supply_class].constantize
      elsif @inventory
        @supply_class = @inventory.supply_class.constantize
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
    
    def find_supplies
      @supplies = @supply_class.was_enabled_at(@date)
    end
end
