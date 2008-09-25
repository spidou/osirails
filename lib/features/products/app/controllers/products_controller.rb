class ProductsController < ApplicationController
  
  # GET /products
  def index
    if params[:product_reference_id].nil?
      @products = Product.paginate(:page => params[:page], :per_page => Product::PRODUCTS_PER_PAGE)
    else
      @products = Product.paginate_all_by_product_reference_id(params[:product_reference_id].split(','), :page => params[:page], :per_page => Product::PRODUCTS_PER_PAGE)
      respond_to do |format|
        format.js {render :layout => false}     
      end
    end 
  end
  
  # GET /products/1
  def show
    @product = Product.find(params[:id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  # GET /products/new
  def new
    
  end

  # GET /products/1/edit
  def edit
    
  end
  
  # POST /products
  def create
    
  end
  
  # PUT /products/1
  def update
    
  end

  # DELETE /products/1
  def destroy
    
  end
  
end
