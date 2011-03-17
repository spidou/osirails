class ProductReferencesController < ApplicationController
  helper :product_reference_categories, :products_catalog
  
  before_filter :find_product_reference, :only => [ :show, :edit, :update, :destroy ]
  
  # GET /product_references
  # GET /product_references?product_reference_sub_category_id=:product_reference_sub_category_id (AJAX)
  # GET /product_references?product_reference_category_id=:product_reference_category_id (AJAX)
  def index
    respond_to do |format|
      format.js do
        if params[:product_reference_sub_category_id]
          @product_references = ProductReference.find_all_by_product_reference_sub_category_id(params[:product_reference_sub_category_id].split(","))
        elsif params[:product_reference_category_id]
          product_reference_categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(","))
          @product_references = ProductReference.find_all_by_product_reference_sub_category_id(product_reference_categories.collect(&:product_reference_sub_categories).flatten)
        else
          @product_references = ProductReference.actives
        end
        
        render :layout => false
      end
      
      format.html { redirect_to product_reference_manager_path }
    end
  end
  
  # GET /product_references/:id
  def show
    respond_to do |format|
      format.html {}
      
      format.json do
        json = JSON.parse(@product_reference.to_json)
        json["product_reference"].merge!(:designation => @product_reference.designation)
        render :json => json
      end
    end
  end
  
  # GET /product_references/new
  # GET /product_references/new?category_id=:product_reference_sub_category_id
  def new
    @product_reference = ProductReference.new(:product_reference_sub_category_id => params[:product_reference_sub_category_id])
    @product_reference_categories = ProductReferenceCategory.roots.actives
  end
  
  # POST /product_references
  def create
    @product_reference = ProductReference.new(params[:product_reference])
    if @product_reference.save
      flash[:notice] = "La référence a été créée avec succès"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      @product_reference_categories = ProductReferenceCategory.roots.actives
      render :action => 'new'
    end
  end
  
  # GET /product_references/:id/edit
  def edit
    @product_reference_categories = ProductReferenceCategory.roots.actives
  end
  
  # PUT /product_references/:id
  def update
    if @product_reference.update_attributes(params[:product_reference])
      flash[:notice] = 'Le produit référence a été modifié avec succès'
      redirect_to(@product_reference)
    else
      @product_reference_categories = ProductReferenceCategory.roots.actives
      render :action => :edit
    end
  end
  
  # DELETE /product_references/:id
  def destroy
    if @product_reference.can_be_destroyed?
      if @product_reference.destroy
        flash[:notice] = "Le produit référence a été supprimé avec succès"
      else
        flash[:error] = "Une erreur est survenue lors de la suppression du produit référence"
      end
      redirect_to product_reference_manager_path
    else
      error_access_page(412)
    end
  end
  
  def auto_complete_for_product_reference_reference
    #OPTMIZE use one sql request instead of multiple requests (using has_search_index once it will be improved to accept by_values requests)
    keywords = params[:product_reference][:reference].split(" ").map(&:strip)
    
    # build query statement for products
    query = []
    conditions = []
    keywords.each do |keyword|
      keyword = "%#{keyword}%"
      query << "(products.reference like ? OR products.name like ? OR products.dimensions like ? OR products.description like ? OR product_reference_categories.reference like ? OR product_reference_categories.name like ? OR product_reference_categories_product_reference_categories.reference like ? OR product_reference_categories_product_reference_categories.name like ?)"
      8.times{ conditions << keyword }
    end
    query = query.join(" AND ")
    conditions.unshift(query)
    @products = ProductReference.all(:include => [ { :product_reference_sub_category => [ :product_reference_category ] } ], :conditions => conditions)
    
    if params[:only] && params[:only] == "product_references"
      @services = []
    else
      # build query statement for services
      query = []
      conditions = []
      keywords.each do |keyword|
        keyword = "%#{keyword}%"
        query << "(service_deliveries.reference like ? OR service_deliveries.name like ? OR service_deliveries.description like ?)"
        3.times{ conditions << keyword }
      end
      query = query.join(" AND ")
      conditions.unshift(query)
      @services = ServiceDelivery.all(:conditions => conditions)
    end
    
    render :partial => 'shared/search_product_reference_auto_complete', :locals => { :products => @products, :services => @services, :keywords => keywords }
  end
  
  private
    def find_product_reference
      @product_reference = ProductReference.find(params[:id])
    end
end
