class SuppliesManagerController < ApplicationController
  helper :supplies_manager, :supplies
  
  before_filter :define_supply_type_and_supply_category_type
  
  # GET /commodities_manager
  # GET /consumables_manager
  def index
    @supply_categories = (params[:inactives] ? @supply_category_type.all : @supply_category_type.enabled)
  end
end
