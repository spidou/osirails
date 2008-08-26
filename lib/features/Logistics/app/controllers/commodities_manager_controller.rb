class CommoditiesManagerController < ApplicationController
  
  def index
    @commodities = Commodity.activates
    @commodities_categories = CommodityCategory.activates
  end
  
end
