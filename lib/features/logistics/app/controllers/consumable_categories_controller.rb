class ConsumableCategoriesController < ApplicationController
  helper :supplies_manager, :supply_categories
  before_filter :supply_type, :only => [:new, :create]
  before_filter :supply_category, :except => [:index, :new, :create]

  # GET /consumable_categories/index
  def index
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/new
  def new
    @category = ConsumableCategory.new(:consumable_category_id => params[:id])
    @categories = ConsumableCategory.enabled_roots
    error_access_page(500) if !["child",nil].include?(params[:type])
  end
  
  # POST /consumable_categories
  def create
    @category = ConsumableCategory.new(params[:consumable_category])
    if @category.save
      flash[:notice] = "La catégorie a été créée"
      redirect_to :controller => 'consumables_manager', :action => 'index'
    else
      unless params[:consumable_category][:consumable_category_id].to_i == 0
        @root_supply_category = params[:consumable_category][:consumable_category_id].to_i
      end
      @categories = ConsumableCategory.enabled_roots
      render :action => 'new'
    end
  end
    
  # PUT /consumable_categories/1
  def update
    respond_to do |format|
      if params[:consumable_category][:name] != "" and @supply_category.update_attributes(params[:consumable_category])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @supply_category }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @supply_category.name}
      end
    end
  end
  
  # DELETE /consumable_categories/1
  def destroy
    if @supply_category.destroy
      flash[:notice] = "La catégorie a été supprimée"
    else
      flash[:error] = "La catégorie ne peut être supprimée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/1/disable
  def disable
    if @supply_category.disable
      flash[:notice] = "La catégorie a été désactivée"
    else
      flash[:error] = "La catégorie ne peut être désactivée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/1/reactivate
  def reactivate
    if @supply_category.reactivate
      flash[:notice] = "La catégorie a été réactivée"
    else
      flash[:error] = "La catégorie ne peut être réactivée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end   
  
  private
    def supply_type
      @supply_type = Consumable
    end
  
    def supply_category
      @supply_category = ConsumableCategory.find(params[:id])
    end
end
