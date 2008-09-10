class ProductsCatalogController < ApplicationController
 
  # GET /products_catalog
  def index
    @categories = ProductReferenceCategory.find( :all, :conditions => {:product_reference_category_id => nil})
    @references = ProductReference.find(:all, :conditions => {:enable => true})
    @products = Product.find(:all)
  end
    
end
