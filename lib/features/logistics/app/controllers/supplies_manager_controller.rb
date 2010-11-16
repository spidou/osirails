class SuppliesManagerController < ApplicationController
  helper :supplies_manager, :supplies
  
  before_filter :define_supply_type_and_supply_category_type
  
  # GET /commodities_manager
  # GET /consumables_manager
  def index
    build_query_for("#{@supply_type.name.underscore}_index")
  end
end
