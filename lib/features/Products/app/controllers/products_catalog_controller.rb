class ProductsCatalogController < ApplicationController
 
  # GET /products_catalog
  def index
    @categories = ProductReferenceCategory.find( :all, :conditions => {:product_reference_category_id => nil})
    @references = ProductReference.find(:all, :conditions => {:enable => true})
    @products = Product.paginate :page => params[:page],:per_page => 10
  end
    
end
