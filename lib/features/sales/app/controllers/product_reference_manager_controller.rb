class ProductReferenceManagerController < ApplicationController
  helper :product_references, :product_reference_categories
  
  # GET /product_reference_manager
  def index
    build_query_for("product_reference_index")
  end
end
