class ProductReferencesController < ApplicationController
  
  # GET /product_references
  def index
    if params[:product_reference_category_id]
      @categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(","))
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to product_reference_manager_path
    end
  end
  
  # GET /product_references/new
  # GET /product_references/new?category_id=:category_id
  def new
    @product_reference = ProductReference.new(:product_reference_category_id => params[:category_id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # GET /product_reference/:id
  def show
    @product_reference = ProductReference.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
    respond_to do |format|
      format.html
      format.js { render :layout => false}
      format.json { render :json => @product_reference }
    end
  end
  
  # GET /product_references/:id/edit
  def edit
    @product_reference = ProductReference.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # POST /product_references
  def create
    @product_reference = ProductReference.new(params[:product_reference])
    if @product_reference.save
      flash[:notice] = "La référence a été créée avec succès"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      @categories = ProductReferenceCategory.find(:all)
      render :action => 'new'
    end
  end
  
  # PUT /product_references/:id
  def update
    @product_reference = ProductReference.find(params[:id])
    @product_reference.counter_update("disable_or_before_update")
    if @product_reference.update_attributes(params[:product_reference])
      @product_reference.counter_update("after_update")
      flash[:notice] = 'La référence a été mise à jour'
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      flash[:error] = 'Une erreur est survenue lors de la mise à jour'
      @categories = ProductReferenceCategory.find(:all)
      render :action => 'edit'
    end
  end
  
  # DELETE /product_references/:id
  def destroy
    @product_reference = ProductReference.find(params[:id])
    if @product_reference.can_be_destroyed?
      @product_reference.destroy
    else
      @product_reference.enable = false
      @product_reference.counter_update("disable_or_before_update")
      @product_reference.save
    end
    
    flash[:notice] = 'La référence a été supprimée' 
    redirect_to :controller => 'product_reference_manager', :action => 'index'
  end
  
end
