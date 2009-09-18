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
      flash[:notice] = "La cat&eacute;gorie a &eacute;t&eacute; cr&eacute;&eacute;e"
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
    @category = ConsumableCategory.find(params[:id])
    if @category.can_be_destroyed?
      if @category.has_children_disable?
        @category.enable = false
        @category.save
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e.'
      else
        @category.destroy
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e.'
      end
    else
      flash[:error] = "La cat&eacute;gorie ne peut &egrave;tre supprim&eacute;e."
    end
    redirect_to :controller => 'consumables_manager', :action => 'index'
  end
   
end
