class ProductsCatalogController < ApplicationController
 
  # GET /products_catalog
  def index
    @categories = ProductReferenceCategory.find( :all, :conditions => {:product_reference_category_id => nil})
    @references = ProductReference.find(:all, :conditions => {:enable => true})
    @products = Product.paginate :page => params[:page], :per_page => Product::PRODUCTS_PER_PAGE
    @type = params[:type]
    respond_to do |format|
      params[:type] == "popup" ? format.html {render :layout => 'popup'} : format.html
      format.js { render :layout => false, :partial => 'products'}
    end
  end
    
end
