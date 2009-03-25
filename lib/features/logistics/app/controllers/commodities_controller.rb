class CommoditiesController < ApplicationController
    
  # GET /commodities/new
  def new
    @commodity = Commodity.new(:commodity_category_id => params[:id]) unless params[:id] == -1
    @categories = CommodityCategory.root_child
    @suppliers = Supplier.find(:all)
    commodity_category = CommodityCategory.find(params[:id]) unless params[:id].to_i == -1
    @unit_measure = UnitMeasure.find(:first)
    @unit_measure = UnitMeasure.find(commodity_category.unit_measure_id) unless params[:id].to_i == -1
  end
  
  # POST /commodities
  def create
    @commodity = Commodity.new(params[:commodity])
    if @commodity.save
      flash[:notice] = "La mati&egrave;re premi&egrave;re a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'commodities_manager', :action => 'index'
    else
      @categories = CommodityCategory.root_child
      @suppliers = Supplier.find(:all)
      @commodity_category_id = params[:commodity][:commodity_category_id]
      render :action => 'new'
    end
  end
  
  # PUT /commodities/1
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
