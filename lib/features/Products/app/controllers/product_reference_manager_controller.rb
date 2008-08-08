class ProductReferenceManagerController < ApplicationController

  # GET /product_reference_manager
  def index
    @categories = ProductReferenceCategory.find( :all, :order => "name" )
    @references = ProductReference.find( :all, :order => "name" , :conditions => { :enable => 1} )
  end
end