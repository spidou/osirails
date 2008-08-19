class ProductReferenceCategoriesController < ApplicationController
  
  # GET /product_reference_categories/new
  def new
    @category = ProductReferenceCategory.new(:product_reference_category_id => params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # GET /product_reference_categories/1/edit
  def edit
    @category = ProductReferenceCategory.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # POST /product_reference_categories
  def create
    @categories = ProductReferenceCategory.find(:all)
    @category = ProductReferenceCategory.new(params[:product_reference_category])
    if @category.save
      flash[:notice] = "La cat&eacute;gorie a &eacute;t&eacute; cr&eacute;&eacute;e"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # PUT /product_reference_categories/1
  def update
    @categories = ProductReferenceCategory.find(:all)
    @category = ProductReferenceCategory.find(params[:id])
    new_parent_category_id = params[:product_reference_category][:product_reference_category_id]
    if @category.can_has_this_parent?(new_parent_category_id)
      @category.change("before_update", @category.product_references_count)
      @category.update_attributes(params[:product_reference_category])
      @category.change("after_update", @category.product_references_count)
      flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; mise &agrave; jour'
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      flash[:error] = 'D&eacute;placement impossible'
      render :action => 'edit'
    end
  end  
  
  # DELETE /product_reference_categories/1
  def destroy
    @category = ProductReferenceCategory.find(params[:id])
    if @category.can_delete?
      @category.destroy
      flash[:notice] = 'La cat&eacute;gorie a &eacute;t&eacute; supprim&eacute;'
    else
      flash[:error] = "Votre cat&eacute;gorie ne peut &egrave;tre supprim&eacute;. V&eacute;rifier que rien ne dépend d'elle."
    end
    redirect_to :controller => 'product_reference_manager', :action => 'index'
  end
  
end
