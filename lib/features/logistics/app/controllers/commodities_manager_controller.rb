class CommoditiesManagerController < ApplicationController
  helper :supplies_manager
  
  # GET /commodities_manager
  def index
    @supply_type = Commodity
    @supply_categories_root = (params[:inactives]=="true" ? CommodityCategory.roots : CommodityCategory.enabled_roots)
  end
end

