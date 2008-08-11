class ProductReferenceManagerController < ApplicationController

  # GET /product_reference_manager
  def index
    @categories = ProductReferenceCategory.find( :all, :order => "product_reference_category_id" )
    @references = ProductReference.find( :all, :order => "product_reference_category_id" , :conditions => { :enable => 1} )
  end
end