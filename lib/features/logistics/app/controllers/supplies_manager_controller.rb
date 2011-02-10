class SuppliesManagerController < ApplicationController
  helper :supplies_manager, :supplies
  
  before_filter :define_supply_class_and_supply_category_class
  
  # GET /commodities_manager
  # GET /consumables_manager
  def index
    build_query_for("#{@supply_class.name.underscore}_index")
  end
end
