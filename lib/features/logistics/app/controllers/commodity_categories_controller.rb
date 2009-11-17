class CommodityCategoriesController < ApplicationController
helper :commodities_manager
  
  # GET /commodity_categories/new
  def new
    @category = CommodityCategory.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.root
    @type = params[:type]
  end
  
  # POST /commodity_categories
  def create
    @category = CommodityCategory.new(params[:commodity_category])
    if @category.save
      flash[:notice] = "La catégorie a été créée"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      unless params[:commodity_category][:commodity_category_id].to_i == 0
        @root_commodity_category = params[:commodity_category][:commodity_category_id].to_i
      end
      @categories = CommodityCategory.root
      render :action => 'new'
    end
  end
    
  # PUT /commodity_categories/1
  def update
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
    if @category.can_be_destroyed?
      if @category.has_children_disable?
        @category.enable = false
        @category.save
        flash[:notice] = 'La catégorie a été supprimée.'
      else
        @category.destroy
        flash[:notice] = 'La catégorie a été supprimée.'
      end
    else
      flash[:error] = "La catégorie ne peut être supprimée."
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
   
end
