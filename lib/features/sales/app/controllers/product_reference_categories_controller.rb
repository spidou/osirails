class ProductReferenceCategoriesController < ApplicationController
  
  # GET /product_reference_categories
  def index
    if params[:product_reference_category_id].nil?
      @categories = ProductReferenceCategory.find(:all)
    else
      @categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(","))
      respond_to do |format|
        format.js {render :layout => false}
      end
    end
  end
  
  # GET /product_reference_categories/new
  # GET /product_reference_categories/new?category_id=:category_id
  def new
    @category = ProductReferenceCategory.new(:product_reference_category_id => params[:category_id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # GET /product_reference_categories/:id
  def show
    @categories = ProductReferenceCategory.find(params[:id].split(","))
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  # GET /product_reference_categories/:id/edit
  def edit
    @category = ProductReferenceCategory.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # POST /product_reference_categories
  def create
    @category = ProductReferenceCategory.new(params[:product_reference_category])
    if @category.save
      flash[:notice] = "La cat&eacute;gorie a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to product_reference_manager_path
    else
      @categories = ProductReferenceCategory.find(:all)
      render :action => 'new'
    end
  end
  
  # PUT /product_reference_categories/:id
  def update
    @category = ProductReferenceCategory.find(params[:id])
    new_parent_category_id = params[:product_reference_category][:product_reference_category_id]
    if @category.can_has_this_parent?(new_parent_category_id)
      @category.counter_update("before_update", @category.product_references_count)
      if @category.update_attributes(params[:product_reference_category])
         @category.counter_update("after_update", @category.product_references_count)
         flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; mise &agrave; jour'
         redirect_to product_reference_manager_path
      else
        @category.counter_update("after_update", @category.product_references_count)
        flash[:error] = 'Erreur dans la mise &agrave; jour'
        render :action => 'edit'
      end
    else
      flash[:error] = 'Erreur dans le d&eacute;placement'
      @categories = ProductReferenceCategory.find(:all)
      render :action => 'edit'
    end
  end  
  
  # DELETE /product_reference_categories/:id
  def destroy
    @category = ProductReferenceCategory.find(params[:id])
    if @category.can_be_destroyed?
      if @category.has_children_disable?
        @category.enable = false
        @category.save
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e'
      else
        @category.destroy
        flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;e'
      end
    else
      flash[:error] = "La cat&eacute;gorie ne peut &egrave;tre supprim&eacute;e. V&eacute;rifiez qu'elle ne poss&egrave;de aucune autre cat&eacute;gorie ou r&eacute;f&eacute;rence."
    end
    redirect_to product_reference_manager_path
  end
  
end
