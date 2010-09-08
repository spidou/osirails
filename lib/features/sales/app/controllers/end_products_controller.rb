class EndProductsController < ApplicationController
  # GET /end_products
  # GET /end_products?product_reference_id=:product_reference_id (AJAX)
  # GET /end_products?product_reference_sub_category_id=:product_reference_sub_category_id (AJAX)
  # GET /end_products?product_reference_category_id=:product_reference_category_id (AJAX)
  def index
    respond_to do |format|
      format.js do
        paginate_options = { :page => params[:page], :per_page => EndProduct::END_PRODUCTS_PER_PAGE }
        
        if params[:product_reference_id] or params[:product_reference_sub_category_id] or params[:product_reference_category_id]
          if params[:product_reference_id]
            product_reference_ids = params[:product_reference_id].split(',')
          elsif params[:product_reference_sub_category_id]
            product_reference_sub_categories = ProductReferenceSubCategory.find(params[:product_reference_sub_category_id].split(','))
            product_reference_ids = product_reference_sub_categories.collect(&:product_references).flatten.collect(&:id)
          elsif params[:product_reference_category_id]
            product_reference_categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(','))
            product_reference_sub_categories = product_reference_categories.collect(&:product_reference_sub_categories).flatten
            product_reference_ids = product_reference_sub_categories.collect(&:product_references).flatten.collect(&:id)
          end
          @end_products = EndProduct.find_all_by_product_reference_id(product_reference_ids).paginate(paginate_options)
        else
          @end_products = EndProduct.paginate(paginate_options)
        end
        render :layout => false
      end
      format.html { error_access_page(400) }
    end
  end

  # GET /end_products/:id
  def show
    @end_product = EndProduct.find(params[:id])
    respond_to do |format|
      format.js { render :layout => false }
      format.html {}
    end
  end
end
