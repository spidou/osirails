class CommodityCategoriesController < ApplicationController
  helper :supplies_manager, :supply_categories

  # GET /commodity_categories/index
  def index
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/new
  def new
    @supply = Commodity.new
    @category = CommodityCategory.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.root
    @type = params[:type]
  end
  
  # POST /commodity_categories
  def create
    @supply = Commodity.new
    @category = CommodityCategory.new(params[:commodity_category])
    if @category.save
      flash[:notice] = "La catégorie a été créée"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      unless params[:commodity_category][:commodity_category_id].to_i == 0
        @root_supply_category = params[:commodity_category][:commodity_category_id].to_i
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
    @commodity_category = CommodityCategory.find(params[:id])
    if @commodity_category.destroy
      flash[:notice] = "La catégorie a été supprimée"
    else
      flash[:error] = "La catégorie ne peut être supprimée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/1/disable
  def disable
    @commodity_category = CommodityCategory.find(params[:id])
    if @commodity_category.disable
      flash[:notice] = "La catégorie a été désactivée"
    else
      flash[:error] = "La catégorie ne peut être désactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/1/reactivate
  def reactivate
    @commodity_category = CommodityCategory.find(params[:id])
    if @commodity_category.reactivate
      flash[:notice] = "La catégorie a été réactivée"
    else
      flash[:error] = "La catégorie ne peut être réactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end   
end
