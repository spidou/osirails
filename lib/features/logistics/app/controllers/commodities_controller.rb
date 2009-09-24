class CommoditiesController < ApplicationController
  helper :supplies_manager, :supplies, :supplier_supplies

  # GET /commodities/index
  def index
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end

  # GET /commodities/new
  def new
    @category = CommodityCategory.new
    @categories = CommodityCategory.root_child
    @supply = Commodity.new(:commodity_category_id => params[:id])
    @suppliers = Supplier.find(:all)
    @unit_measure = UnitMeasure.find(CommodityCategory.find(params[:id]).unit_measure_id)
  end

  # GET /commodities/1
  def show
    @supply = Supply.find(params[:id])
    @category = CommodityCategory.new
    @categories = CommodityCategory.root_child
    @unit_measure = UnitMeasure.find(@supply.commodity_category.unit_measure_id)
    @supply_category_id = @supply.commodity_category_id
  end

  # POST /commodities
  def create
    @supply = Commodity.new(params[:commodity])
    if @supply.save
      flash[:notice] = "La matière première a été créée avec succès"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      @categories = CommodityCategory.root_child
      @suppliers = Supplier.find(:all)
      @category = CommodityCategory.new
      @unit_measure = UnitMeasure.find(CommodityCategory.find(params[:commodity][:commodity_category_id]).unit_measure_id)
      render :action => 'new'
    end
  end

  # GET /commodities/1/edit
  def edit
    @supply = Supply.find(params[:id])
    @category = CommodityCategory.new
    @categories = CommodityCategory.root_child
    @unit_measure = UnitMeasure.find(@supply.commodity_category.unit_measure_id)
    @supply_category_id = @supply.commodity_category_id
  end

  # PUT /commodities/1
  def update
    @supply = Commodity.find(params[:id])
    respond_to do |format|
      if params[:commodity].values[0] != "" and @supply.update_attributes(params[:commodity])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @supply }
      else
        @category = CommodityCategory.new
        @categories = CommodityCategory.root_child
        @unit_measure = UnitMeasure.find(@supply.commodity_category.unit_measure_id)
        key = params[:commodity].keys[0]
        format.html { render :action => "edit" }
        format.json { render :json => @supply["#{key}"] }
      end
    end
  end

  # DELETE /commodities/1
  def destroy
    @commodity = Commodity.find(params[:id])
    if @commodity.destroy
      flash[:notice] = "La matière première a été supprimée"
    else
      flash[:error] = "La matière première ne peut être supprimée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodities/1/disable
  def disable
    @commodity = Commodity.find(params[:id])
    if @commodity.disable
      flash[:notice] = "La matière première a été désactivée"
    else
      flash[:error] = "La matière première ne peut être désactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
  # GET /commodities/1/reactivate
  def reactivate
    @commodity = Commodity.find(params[:id])
    if @commodity.reactivate
      flash[:notice] = "La matière première a été réactivée"
    else
      flash[:error] = "La matière première ne peut être réactivée"
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
end
