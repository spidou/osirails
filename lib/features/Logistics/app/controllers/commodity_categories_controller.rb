class CommodityCategoriesController < ApplicationController
  
  # GET /commodity_categories/new
  def new
    @category = CommodityCategory.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.root
    @type = params[:type]
  end
  
  # POST /commodity_categories
  def create
    @categories = CommodityCategory.root
    @category = CommodityCategory.new(params[:commodity_category])
    if @category.save
      flash[:notice] = "La cat&eacute;gorie a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # DELETE /commodity_categories/1
  def destroy
    @category = CommodityCategory.find(params[:id])
    if @category.can_destroy?
      if @category.destroy
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e'
      else
        flash[:error] = "La cat&eacute;gorie ne peut &egrave;tre supprim&eacute;e."
      end
    else
      @category.enable = false
      flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e'
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
end