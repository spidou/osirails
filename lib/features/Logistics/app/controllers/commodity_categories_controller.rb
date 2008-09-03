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
      unless params[:commodity_category][:commodity_category_id].to_i == 0
        @root_commodity_category = params[:commodity_category][:commodity_category_id].to_i
      end
      render :action => 'new'
    end
  end
    
  def update #TODO Régler le probleme du validates prensence avec le in line
    @commodity_category = CommodityCategory.find(params[:id])
    respond_to do |format|
      if params[:commodity_category][:name] != "" and @commodity_category.update_attributes(params[:commodity_category])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @commodity_category }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @commodity_category.name}
      end
    end
  end
  
  # DELETE /commodity_categories/1
  def destroy
    @category = CommodityCategory.find(params[:id])
    if @category.can_destroy?
      if @category.has_children_disable?
        @category.enable = false
        @category.save
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e.'
      else
        @category.destroy
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e.'
      end
    else
      flash[:error] = "La cat&eacute;gorie ne peut &egrave;tre supprim&eacute;e."
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
   
end