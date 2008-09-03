class InventoriesController < ApplicationController
  
    # GET /inventories
  def index
    @inventories = Inventory.find(:all, :order => 'id').reverse
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
    else
      flash[:error] = "Impossible de cr&eacute;er un nouvelle inventaire. V&eacute;rifi&eacute; que  les inventaires sont cl&ocirc;tur&eacute;s"
    end
    redirect_to :action => 'index'
  end
  
  def closed
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
