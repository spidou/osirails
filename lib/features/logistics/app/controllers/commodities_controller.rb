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
    @supply = Commodity.new(:commodity_category_id => params[:id] == -1 ? @categories.first.id : params[:id])
    @suppliers = Supplier.find(:all)
    @unit_measure = UnitMeasure.find(params[:id] == '-1' ? @categories.first.unit_measure_id : CommodityCategory.find(params[:id]).unit_measure_id)
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
      flash[:notice] = "La mati&egrave;re premi&egrave;re a &eacute;t&eacute; cr&eacute;&eacute;e"
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
    if @commodity.can_be_destroyed?
      if @commodity.destroy
        flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
      else
        flash[:error] = 'Erreur lors de la suppression'
      end
    else
      @commodity.enable = false
      @commodity.counter_update
      if @commodity.save
        flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
      else
        flash[:error] = 'Erreur lors de la suppression'
      end
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end

end

