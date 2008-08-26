class CommoditiesController < ApplicationController
    
  # GET /commodities/new
  def new
    @commodity = Commodity.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.root_child
    @suppliers = Supplier.find(:all)
  end
  
  # POST /commodities
  def create
    @categories = CommodityCategory.root_child
    @commodity = Commodity.new(params[:commodity])
    if @commodity.save
      flash[:notice] = "La mati&egrave;re premi&egrave;re a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # DELETE /commodities/1
  def destroy
    @commodity = Commodity.find(params[:id])
    if @commodity.can_destroy?
      if @commodity.destroy
        flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
      else
        flash[:error] = "La mati&egrave;re premi&egrave;re ne peut &egrave;tre supprim&eacute;e."
      end
    else
      @commodity.enable = false
      flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
end
