class ProductsCatalogController < ApplicationController
  
  # GET /products_catalog
  def index
    @product_reference_categories = ProductReferenceCategory.roots.actives
    @product_reference_sub_categories = ProductReferenceSubCategory.actives
    @product_references = ProductReference.actives
    @end_products = EndProduct.paginate(:page => params[:page], :per_page => EndProduct::END_PRODUCTS_PER_PAGE)
    @type = params[:type]
    respond_to do |format|
      params[:type] == "popup" ? format.html { render :layout => 'popup' } : format.html
      format.js { render :layout => false, :partial => 'end_products' }
    end
  end
    
end
