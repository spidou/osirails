class ProductReferencesController < ApplicationController

  # GET /product_references/new
  def new
    @reference = ProductReference.new
    @categories = ProductReferenceCategory.find(:all)
  end

  # GET /product_references/1/edit
  def edit
    @reference = ProductReference.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end

  
  # POST /product_references
  def create
    @reference = ProductReference.new(params[:product_reference])
    if @reference.save
      flash[:notice] = @reference.name + " cr&eacute;e avec succ&egrave;s"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # PUT /product_references/1
  def update
    @categories = ProductReferenceCategory.find(:all)
    @reference = ProductReference.find(params[:id])
    old_category_id = @reference.product_reference_category_id
    if @reference.update_attributes(params[:product_reference])
      #      ProductReferenceCategory.update_counters old_category_id, :product_references_count => - 1
      #      ProductReferenceCategory.update_counters @reference.product_reference_category_id, :product_references_count => 1
      flash[:notice] = 'La r&eacute;f&eacute;rence est bien mis &agrave; jour'
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      flash[:error] = 'Une erreur est survenue dans la mise &agrave; jour'
      render :action => 'edit'
    end
  end

  # DELETE /product_references/1
  def destroy
    @reference = ProductReference.find(params[:id])
    if @reference.can_delete?
      @reference.destroy
      flash[:notice] = 'Votre r&eacute;f&eacute;rence est bien supprim&eacute;'
    else
      @reference.enable = 0
      @reference.change_count
      @reference.save
      flash[:notice] = 'Votre r&eacute;f&eacute;rence est bien supprim&eacute;' 
    end
    redirect_to :controller => 'product_reference_manager', :action => 'index'
  end
  
end