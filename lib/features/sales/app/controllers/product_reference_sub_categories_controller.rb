class ProductReferenceSubCategoriesController < ProductReferenceCategoriesController
  
  # GET /product_reference_sub_categories
  def index
    respond_to do |format|
      format.js do
        if params[:product_reference_category_id].blank?
          @product_reference_categories = @product_reference_category_type.actives
        else
          @product_reference_categories = @product_reference_category_type.find_all_by_product_reference_category_id(params[:product_reference_category_id].split(","))
        end
        render :layout => false
      end
    end
  end
  
  # GET /product_reference_sub_categories/new
  # GET /product_reference_sub_categories/new?product_reference_category_id=:product_reference_category_id
  def new
    @product_reference_category = @product_reference_category_type.new(:product_reference_category_id => params[:product_reference_category_id])
    @product_reference_categories = @product_reference_category_type.roots.actives
  end
  
  private
    def define_product_reference_category_type
      @product_reference_category_type = ProductReferenceSubCategory
    end
end
