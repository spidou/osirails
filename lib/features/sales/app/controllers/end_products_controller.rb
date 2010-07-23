class EndProductsController < ApplicationController
  # GET /end_products
  def index
    if params[:product_reference_id].nil?
      @end_products = EndProduct.paginate(:page => params[:page], :per_page => EndProduct::END_PRODUCTS_PER_PAGE)
    else
      @end_products = EndProduct.paginate_all_by_product_reference_id(params[:product_reference_id].split(','), :page => params[:page], :per_page => EndProduct::END_PRODUCTS_PER_PAGE)
    end
    respond_to do |format|
      format.html { error_access_page(400) }
      format.js { render :layout => false }
    end
  end

  # GET /end_products/:id
  def show
    @end_product = EndProduct.find(params[:id])
    respond_to do |format|
      format.html { error_access_page(400) }
      format.js { render :layout => false }
    end
  end
end
