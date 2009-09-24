class ConsumableCategoriesController < ApplicationController
  helper :supplies_manager, :supply_categories

  # GET /consumable_categories/index
  def index
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/new
  def new
    @supply = Consumable.new
    @category = ConsumableCategory.new(:consumable_category_id => params[:id])
    @categories = ConsumableCategory.root
    @type = params[:type]
  end
  
  # POST /consumable_categories
  def create
    @supply = Consumable.new
    @category = ConsumableCategory.new(params[:consumable_category])
    if @category.save
      flash[:notice] = "La catégorie a été créée"
      redirect_to :controller => 'consumables_manager', :action => 'index'
    else
      unless params[:consumable_category][:consumable_category_id].to_i == 0
        @root_supply_category = params[:consumable_category][:consumable_category_id].to_i
      end
      @categories = ConsumableCategory.root
      render :action => 'new'
    end
  end
    
  # PUT /consumable_categories/1
  def update
    @consumable_category = ConsumableCategory.find(params[:id])
    respond_to do |format|
      if params[:consumable_category][:name] != "" and @consumable_category.update_attributes(params[:consumable_category])
        format.html { redirect_to(:action => "index") }
        format.json { render :json => @consumable_category }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @consumable_category.name}
      end
    end
  end
  
  # DELETE /consumable_categories/1
  def destroy
    @consumable_category = ConsumableCategory.find(params[:id])
    if @consumable_category.destroy
      flash[:notice] = "La catégorie a été supprimée"
    else
      flash[:error] = "La catégorie ne peut être supprimée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/1/disable
  def disable
    @consumable_category = ConsumableCategory.find(params[:id])
    if @consumable_category.disable
      flash[:notice] = "La catégorie a été désactivée"
    else
      flash[:error] = "La catégorie ne peut être désactivée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
  
  # GET /consumable_categories/1/reactivate
  def reactivate
    @consumable_category = ConsumableCategory.find(params[:id])
    if @consumable_category.reactivate
      flash[:notice] = "La catégorie a été réactivée"
    else
      flash[:error] = "La catégorie ne peut être réactivée"
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end   
end
