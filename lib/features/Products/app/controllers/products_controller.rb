class ProductsController < ApplicationController
  
  # GET /products
  def index
    unless params[:id].nil?
    @products = Product.find_all_by_product_reference_id(params[:id])
    render :layout => false
    end
  end
  
  # GET /products/1
  def show
    @product = Product.find(params[:id])
    render :layout => false
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
