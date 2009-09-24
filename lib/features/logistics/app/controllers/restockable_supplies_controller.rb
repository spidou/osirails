class RestockableSuppliesController < ApplicationController
  
  # GET /restockable_supplies
  def index        
    @commodities_to_restock = Commodity.restockables.paginate(:page => params[:page], :per_page => Supply::SUPPLIES_PER_PAGE)
    @consumables_to_restock = Consumable.restockables.paginate(:page => params[:page], :per_page => Supply::SUPPLIES_PER_PAGE)
  end

end
