class CommoditiesManagerController < ApplicationController

  # GET /commodities_manager
  def index
    @type = params[:type]
    @commodities_categories_root = CommodityCategory.root
    @commodities_categories_root_child = CommodityCategory.root_child
    @commodities = Commodity.activates
    @last_inventory = Inventory.last
  end

end
