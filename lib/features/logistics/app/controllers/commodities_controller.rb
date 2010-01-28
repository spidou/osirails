class CommoditiesController < ApplicationController
  helper :supplies_manager, :supplies, :supplier_supplies
  before_filter :supply,                      :except => [:index, :new, :create]
  before_filter :supply_category_type,        :except => [:index, :destroy, :disable, :reactivate]
  before_filter :categories_and_suppliers,    :only   => [:new, :create]
  before_filter :categories_and_unit_measure, :only   => [:show, :edit, :update]

  # GET /commodities
  def index
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end

  # GET /commodities/new
  # GET /commodities/new?id=:id # :id corresponds to a commodity category id
  def new
    @supply = Commodity.new(:commodity_category_id => params[:id])
    @unit_measure = UnitMeasure.find(CommodityCategory.find(params[:id]).unit_measure_id)
  end

  # GET /commodities/:id
  def show
    @categories = CommodityCategory.roots_children
    @unit_measure = UnitMeasure.find(@supply.supply_category.unit_measure_id)
    @supply_category_id = @supply.commodity_category_id
  end

  # POST /commodities
  def create
    @supply = Commodity.new(params[:commodity])
    if @supply.save
      flash[:notice] = "La matière première a été créée avec succès"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      @unit_measure = UnitMeasure.find(CommodityCategory.find(params[:commodity][:commodity_category_id]).unit_measure_id)
      render :action => 'new'
    end
  end

  # GET /commodities/:id/edit
  def edit
    @supply_category_id = @supply.commodity_category_id
  end

  # PUT /commodities/:id
  def update
    respond_to do |format|
      if params[:commodity].values[0] != "" and @supply.update_attributes(params[:commodity])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @supply }
      else
        key = params[:commodity].keys[0]
        format.html { render :action => "edit" }
        format.json { render :json => @supply["#{key}"] }
      end
    end
  end

  # DELETE /commodities/:id
  def destroy
    if @supply.destroy
      flash[:notice] = "La matière première a été supprimée"
    else
      flash[:error] = "La matière première ne peut être supprimée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodities/:id/disable
  def disable
    if @supply.disable
      flash[:notice] = "La matière première a été désactivée"
    else
      flash[:error] = "La matière première ne peut être désactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodities/:id/reactivate
  def reactivate
    if @supply.reactivate
      flash[:notice] = "La matière première a été réactivée"
    else
      flash[:error] = "La matière première ne peut être réactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  private
    def supply
      @supply = Commodity.find(params[:id])
    end
    
    def supply_category_type
      @category = CommodityCategory
    end
    
    def categories_and_suppliers
      @categories = CommodityCategory.roots_children
      @suppliers = Supplier.find(:all)    
    end
    
    def categories_and_unit_measure
      @categories = CommodityCategory.roots_children
      @unit_measure = UnitMeasure.find(@supply.supply_category.unit_measure_id)
    end
end
