class ProductReferenceCategoriesController < ApplicationController
  helper :products_catalog
  
  before_filter :define_product_reference_category_type
  before_filter :find_product_reference_category, :except => [ :index, :new, :create ]
  
  # GET /product_reference_categories
  def index
    @product_reference_categories = @product_reference_category_type.roots.actives
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  # GET /product_reference_categories/:id
  def show
    @categories = ProductReferenceCategory.find(params[:id].split(","))
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  # GET /product_reference_categories/new
  def new
    @product_reference_category = @product_reference_category_type.new
    @product_reference_categories = @product_reference_category_type.roots.actives
  end
  
  # POST /product_reference_categories
  def create
    @product_reference_category = @product_reference_category_type.new(params[@product_reference_category_type.name.underscore.to_sym])
    if @product_reference_category.save
      flash[:notice] = "La famille de produit a été créée avec succès"
      redirect_to @product_reference_category
    else
      render :action => :new
    end
  end
  
  # GET /product_reference_categories/:id/edit
  def edit
  end
  
  # PUT /product_reference_categories/:id
  def update
    if @product_reference_category.update_attributes(params[@product_reference_category_type.name.underscore.to_sym])
      flash[:notice] = 'La famille de produit a été modifiée avec succès'
      redirect_to @product_reference_category
    else
      render :action => :edit
    end
    
    #@category = ProductReferenceCategory.find(params[:id])
    #new_parent_category_id = params[:product_reference_category][:product_reference_category_id]
    #if @category.can_has_this_parent?(new_parent_category_id)
    #  @category.counter_update("before_update", @category.product_references_count)
    #  if @category.update_attributes(params[:product_reference_category])
    #     @category.counter_update("after_update", @category.product_references_count)
    #     flash[:notice] = 'La catégorie a été mise à jour'
    #     redirect_to product_reference_manager_path
    #  else
    #    @category.counter_update("after_update", @category.product_references_count)
    #    flash[:error] = 'Erreur dans la mise à jour'
    #    render :action => 'edit'
    #  end
    #else
    #  flash[:error] = 'Erreur dans le déplacement'
    #  @categories = ProductReferenceCategory.find(:all)
    #  render :action => 'edit'
    #end
  end
  
  # DELETE /product_reference_categories/:id
  def destroy
    if @product_reference_category.can_be_destroyed?
      if @product_reference_category.destroy
        flash[:notice] = "La famille de produit a été supprimée avec succès"
      else
        flash[:error] = "Une erreur est survenue lors de la suppression de la famille de produit"
      end
      redirect_to product_reference_manager_path
    else
      error_access_page(412)
    end
  end
  
  # GET /update_product_reference_sub_categories?id=:id (AJAX)
  def update_product_reference_sub_categories
    product_reference_categories = @product_reference_category ? @product_reference_category.product_reference_sub_categories.actives : []
    render :partial => 'product_reference_sub_categories/product_reference_sub_categories', :object => product_reference_categories
  end
  
  private
    def define_product_reference_category_type
      @product_reference_category_type = ProductReferenceCategory
    end
    
    def find_product_reference_category
      id = params[:id] || params["#{@product_reference_category_type.name.underscore}_id".to_sym]
      @product_reference_category = @product_reference_category_type.find(id)
    end
end
