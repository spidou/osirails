class CommodityCategoriesController < ApplicationController
  helper :supplies_manager, :supply_categories
  before_filter :supply_type, :only => [:new, :create]
  before_filter :supply_category, :except => [:index, :new, :create]

  # GET /commodity_categories/index
  def index
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/new
  def new
    @category = CommodityCategory.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.enabled_roots
    error_access_page(500) if !["child",nil].include?(params[:type])
  end
  
  # POST /commodity_categories
  def create
    @category = CommodityCategory.new(params[:commodity_category])
    if @category.save
      flash[:notice] = "La catégorie a été créée"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      unless params[:commodity_category][:commodity_category_id].to_i == 0
        @root_supply_category = params[:commodity_category][:commodity_category_id].to_i
      end
      @categories = CommodityCategory.enabled_roots
      render :action => 'new'
    end
  end
    
  # PUT /commodity_categories/1
  def update
    respond_to do |format|
      if params[:commodity_category][:name] != "" and @supply_category.update_attributes(params[:commodity_category])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @supply_category }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @supply_category.name}
      end
    end
  end
  
  # DELETE /commodity_categories/1
  def destroy
    if @supply_category.destroy
      flash[:notice] = "La catégorie a été supprimée"
    else
      flash[:error] = "La catégorie ne peut être supprimée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/1/disable
  def disable
    if @supply_category.disable
      flash[:notice] = "La catégorie a été désactivée"
    else
      flash[:error] = "La catégorie ne peut être désactivée"

    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodity_categories/1/reactivate
  def reactivate
    if @supply_category.reactivate
      flash[:notice] = "La catégorie a été réactivée"
    else
      flash[:error] = "La catégorie ne peut être réactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end   
  
  private
    def supply_type
      @supply_type = Commodity    
    end
  
    def supply_category
      @supply_category = CommodityCategory.find(params[:id])
    end
end
