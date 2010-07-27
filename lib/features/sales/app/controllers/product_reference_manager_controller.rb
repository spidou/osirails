class ProductReferenceManagerController < ApplicationController

  # GET /product_reference_manager
  def index
    @categories = ProductReferenceCategory.all(:order => :product_reference_category_id)
    @references = ProductReference.actives
    @display = params[:display] || "active"
  end
end
