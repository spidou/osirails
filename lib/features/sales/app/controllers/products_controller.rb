class ProductsController < ApplicationController

  # GET /products
  def index
    if params[:product_reference_id].nil?
      @products = Product.paginate(:page => params[:page], :per_page => Product::PRODUCTS_PER_PAGE)
    else
      @products = Product.paginate_all_by_product_reference_id(params[:product_reference_id].split(','), :page => params[:page], :per_page => Product::PRODUCTS_PER_PAGE)
    end
    respond_to do |format|
      format.js { render :layout => false }
      format.html { error_access_page(400) }
    end
  end

  # GET /products/1
  def show
    @product = Product.find(params[:id])
    respond_to do |format|
      format.html { error_access_page(400) }
      format.js { render :layout => false }
    end
  end
end
