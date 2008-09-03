class CommoditiesController < ApplicationController
    
  # GET /commodities/new
  def new
    @commodity = Commodity.new(:commodity_category_id => params[:id])
    @categories = CommodityCategory.root_child
    @suppliers = Supplier.find(:all)
    commodity_category = CommodityCategory.find(params[:id])
    @unit_measure = UnitMeasure.find(commodity_category.unit_measure_id)
  end
  
  # POST /commodities
  def create
    @categories = CommodityCategory.root_child
    @suppliers = Supplier.find(:all)
    @commodity = Commodity.new(params[:commodity])
    if @commodity.save
      flash[:notice] = "La mati&egrave;re premi&egrave;re a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      @commodity_category_id = params[:commodity][:commodity_category_id]
      render :action => 'new'
    end
  end
  
  def update
    @commodity = Commodity.find(params[:id])
    respond_to do |format|
      if params[:commodity].values[0] != "" and @commodity.update_attributes(params[:commodity])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @commodity }
      else
        key = params[:commodity].keys[0]
        format.html { render :action => "edit" }
        format.json { render :json => @commodity["#{key}"] }
      end
    end
  end

  
  # DELETE /commodities/1
  def destroy
    @commodity = Commodity.find(params[:id])
    if @commodity.can_destroy?
      @commodity.destroy
      flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
    else
      @commodity.enable = false
      @commodity.counter_update
      @commodity.save
      flash[:notice] = 'La mati&egrave;re premi&egrave;re a &eacute;t&eacute; supprim&eacute;e'
    end
    redirect_to :controller => 'commodities_manager', :action => 'index'
  end
  
end
