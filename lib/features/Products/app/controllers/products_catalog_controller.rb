class ProductsCatalogController < ApplicationController
 
  # GET /products_catalog
  def index
    @reference_id = -1
    @categories = ProductReferenceCategory.find( :all, :conditions => {:product_reference_category_id => nil})
    @products = Product.find(:all)
  end
  
  # This method permit to show product table
  def show_product_tab
    @products = Product.find(:all, :conditions => {:product_reference_id => params[:parameter].to_i})
    render :partial => 'show_product_tab'
  end
  
    # This method permit to show references
  def show_references
    @reference_id = params[:parameter].to_i
    render :partial => 'show_references'
  end
  
  # This method permit to show references informations
  def show_reference_information
    @reference_id = params[:parameter].to_i
    render :partial => 'show_reference_information'
  end
  
  # This method permit to show products informations
  def show_product_information
    @product = Product.find_by_id(params[:id].to_i)
    render :partial => 'show_product_information'
  end
  
end