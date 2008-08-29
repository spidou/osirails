class InventoriesController < ApplicationController
  
  def index
    @inventories = Inventory.find(:all)
  end
  
  def show
    @inventory = Inventory.find(params[:id])
    @commodities = Commodity.find(:all)
  end
  
  def new
    @inventory = Inventory.create
    commodities = Commodity.activates
    flash[:notice] = commodities.first.name
    @inventory.create_inventory(commodities)
    redirect_to :action => 'index'
  end

end
