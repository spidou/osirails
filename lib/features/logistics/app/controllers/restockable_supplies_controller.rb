class RestockableSuppliesController < ApplicationController
  
  # GET /restockable_supplies
  def index        
    @commodities_to_restock = Commodity.restockables
    @consumables_to_restock = Consumable.restockables
  end

end
