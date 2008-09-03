class CommoditiesInventoriesController < ApplicationController
  
  def update
    @commodity_inventory = CommoditiesInventory.find(params[:id])
    @inventory = Inventory.find(@commodity_inventory.inventory_id)
    respond_to do |format|
      if params[:commodities_inventory].values[0] != "" and @commodity_inventory.update_attributes(params[:commodities_inventory])
        format.html { redirect_to(:action => "show", :object => @inventory) }
        format.json { render :json => @commodity_inventory }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @commodity_inventory.quantity}
      end
    end
  end

end