class ConsumablesController < ApplicationController
  helper :supplies_manager, :supplies, :supplier_supplies

  # GET /consumables/index
  def index
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end

  # GET /consumables/new
  def new
    @category = ConsumableCategory.new
    @categories = ConsumableCategory.root_child
    @supply = Consumable.new(:consumable_category_id => params[:id] == -1 ? @categories.first.id : params[:id])
    @suppliers = Supplier.find(:all)
    @unit_measure = UnitMeasure.find(params[:id] == '-1' ? @categories.first.unit_measure_id : ConsumableCategory.find(params[:id]).unit_measure_id)
  end

  # GET /consumables/1
  def show
    @supply = Supply.find(params[:id])
    @category = ConsumableCategory.new
    @categories = ConsumableCategory.root_child
    @unit_measure = UnitMeasure.find(@supply.consumable_category.unit_measure_id)
    @supply_category_id = @supply.consumable_category_id
  end

  # POST /consumables
  def create
    @supply = Consumable.new(params[:consumable])
    if @supply.save
      flash[:notice] = "La mati&egrave;re premi&egrave;re a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'consumables_manager', :action => 'index'
    else
      @categories = ConsumableCategory.root_child
      @suppliers = Supplier.find(:all)
      @category = ConsumableCategory.new
      @unit_measure = UnitMeasure.find(ConsumableCategory.find(params[:consumable][:consumable_category_id]).unit_measure_id)
      render :action => 'new'
    end
  end

  # GET /consumables/:id/edit
  def edit
    @supply = Supply.find(params[:id])
    @category = ConsumableCategory.new
    @categories = ConsumableCategory.root_child
    @unit_measure = UnitMeasure.find(@supply.consumable_category.unit_measure_id)
    @supply_category_id = @supply.consumable_category_id
  end

  # PUT /consumables/1
  def update
    @consumable = Consumable.find(params[:id])
    respond_to do |format|
      if params[:consumable].values[0] != "" and @consumable.update_attributes(params[:consumable])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @consumable }
      else
        key = params[:consumable].keys[0]
        format.html { render :action => "edit" }
        format.json { render :json => @consumable["#{key}"] }
      end
    end
  end

  # DELETE /consumables/1
  def destroy
    @consumable = Consumable.find(params[:id])
    if @consumable.can_be_destroyed?
      if @consumable.destroy
        flash[:notice] = 'Le consommable a été supprimé'
      else
        flash[:error] = 'Erreur lors de la suppression'
      end
    else
      @consumable.enable = false
      @consumable.counter_update
      if @consumable.save
        flash[:notice] = 'Le consommable a été supprimé'
      else
        flash[:error] = 'Erreur lors de la suppression'
      end
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end

end

