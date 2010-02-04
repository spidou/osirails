class ConsumablesController < ApplicationController
  helper :supplies_manager, :supplies, :supplier_supplies
  before_filter :supply, :except => [:index, :new, :create]
  before_filter :supply_category_type, :except => [:index, :destroy, :disable, :reactivate]
  before_filter :categories_and_suppliers, :only => [:new, :create]
  before_filter :categories_and_unit_measure, :only => [:show, :edit, :update]

  # GET /consumables/index
  def index
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end

  # GET /consumables/new
  def new
    @supply = Consumable.new(:consumable_category_id => params[:id])
    @unit_measure = UnitMeasure.find(ConsumableCategory.find(params[:id]).unit_measure_id)
  end

  # GET /consumables/1
  def show
    @categories = ConsumableCategory.roots_children
    @unit_measure = UnitMeasure.find(@supply.supply_category.unit_measure_id)
    @supply_category_id = @supply.consumable_category_id
  end

  # POST /consumables
  def create
    @supply = Consumable.new(params[:consumable])
    if @supply.save
      flash[:notice] = "Le consommable a été créé avec succès"
      redirect_to :controller => 'consumables_manager', :action => 'index'
    else
      @unit_measure = UnitMeasure.find(ConsumableCategory.find(params[:consumable][:consumable_category_id]).unit_measure_id)
      render :action => 'new'
    end
  end

  # GET /consumables/1/edit
  def edit
    @supply_category_id = @supply.consumable_category_id
  end

  # PUT /consumables/1
  def update
    respond_to do |format|
      if params[:consumable].values[0] != "" and @supply.update_attributes(params[:consumable])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @supply }
      else
        key = params[:consumable].keys[0]
        format.html { render :action => "edit" }
        format.json { render :json => @supply["#{key}"] }
      end
    end
  end

  # DELETE /consumables/1
  def destroy
    if @supply.destroy
      flash[:notice] = "Le consommable a été supprimé"
    else
      flash[:error] = "Le consommable ne peut être supprimé"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumables/1/disable
  def disable
    if @supply.disable
      flash[:notice] = "Le consommable a été désactivé"
    else
      flash[:error] = "Le consommable ne peut être désactivé"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumables/1/reactivate
  def reactivate
    if @supply.reactivate
      flash[:notice] = "Le consommable a été réactivé"
    else
      flash[:error] = "Le consommable ne peut être réactivé"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  private
    def supply
      @supply = Consumable.find(params[:id])
    end
    
    def supply_category_type
      @category = ConsumableCategory
    end
    
    def categories_and_suppliers
      @categories = ConsumableCategory.roots_children
      @suppliers = Supplier.find(:all)    
    end
    
    def categories_and_unit_measure
      @categories = ConsumableCategory.roots_children
      @unit_measure = UnitMeasure.find(@supply.supply_category.unit_measure_id)
    end
end
