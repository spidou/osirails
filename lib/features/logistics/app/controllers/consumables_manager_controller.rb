class ConsumablesManagerController < ApplicationController
  helper :supplies_manager
  
  # GET /consumables_manager
  def index
    @supply_type = Consumable
    @supply_categories_root = (params[:inactives]=="true" ? ConsumableCategory.roots : ConsumableCategory.enabled_roots)
  end
end

