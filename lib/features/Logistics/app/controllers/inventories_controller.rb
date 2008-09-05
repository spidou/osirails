class InventoriesController < ApplicationController
  
    # GET /inventories
  def index
    @inventories = Inventory.find(:all, :order => 'id').reverse
    @inventory_closed = Inventory.find_all_by_closed(false)
  end
  
    # GET /inventories/1
  def show
    @inventory = Inventory.find(params[:id])
  end
  
    # GET /inventories/new
  def new
    @inventories = Inventory.find(:all, :conditions => {:closed => false})
    if @inventories.empty?
      @inventory = Inventory.create
      commodities = Commodity.activates
      @inventory.create_inventory(commodities)
      redirect_to :action => 'show', :id => Inventory.find(:last)
    else
      flash[:error] = "Impossible de cr&eacute;er un nouvelle inventaire. V&eacute;rifi&eacute; que  les inventaires sont cl&ocirc;tur&eacute;s"
      params[:type] == "inventory" ? redirect_to(:action => 'index') : redirect_to(:controller => 'commodities_manager', :action => 'index')
    end
  end
  
   # PUT /inventories/1
  def update
    @inventory = Inventory.find(params[:id])
    if @inventory.inventory_closed?
      flash[:error] = "L'inventaire est d&eacute;j&agrave; cl&ocirc;tur&eacute;"
    else
      @inventory.closed = true
      @inventory.save
    end
    redirect_to :action => 'index'
  end
  
end
