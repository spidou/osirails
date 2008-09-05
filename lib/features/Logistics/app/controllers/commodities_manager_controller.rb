class CommoditiesManagerController < ApplicationController

  def index
    @type = params[:type]
    @commodities_categories_root = CommodityCategory.root
    @commodities_categories_root_child = CommodityCategory.root_child
    @commodities = Commodity.activates
    @inventory =  Inventory.find(:last)
  end

end