class ProductReferenceManagerController < ApplicationController

  # GET /product_reference_manager
  def index
    @categories = ProductReferenceCategory.find(:all, :order => "product_reference_category_id")
    @references = ProductReference.find_all_by_id(:conditions => {:enable => true})
    @type = params[:type]
  end
end
