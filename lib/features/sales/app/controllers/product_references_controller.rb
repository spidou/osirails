class ProductReferencesController < ApplicationController
  
  # GET /product_references
  def index
    if params[:product_reference_category_id]
      @categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(","))
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to product_reference_manager_path
    end
  end
  
  # GET /product_references/:id
  def show
    @product_reference = ProductReference.find(params[:id])
    respond_to do |format|
      format.html {
        @categories = ProductReferenceCategory.find(:all)
      }
      format.js {
        @categories = ProductReferenceCategory.find(:all)
        render :layout => false
      }
      
      format.json {
        json = JSON.parse(@product_reference.to_json)
        json["product_reference"].merge!(:designation => @product_reference.designation)
        render :json => json
      }
    end
  end
  
  # GET /product_references/new
  # GET /product_references/new?category_id=:category_id
  def new
    @product_reference = ProductReference.new(:product_reference_category_id => params[:category_id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # POST /product_references
  def create
    @product_reference = ProductReference.new(params[:product_reference])
    if @product_reference.save
      flash[:notice] = "La référence a été créée avec succès"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      @categories = ProductReferenceCategory.find(:all)
      render :action => 'new'
    end
  end
  
  # GET /product_references/:id/edit
  def edit
    @product_reference = ProductReference.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # PUT /product_references/:id
  def update
    @product_reference = ProductReference.find(params[:id])
    if @product_reference.update_attributes(params[:product_reference])
      flash[:notice] = 'Le produit référence a été modifié avec succès'
      redirect_to(@product_reference)
    else
      @categories = ProductReferenceCategory.find(:all)
      render :action => :edit
    end
  end
  
#  # DELETE /product_references/:id
#  def destroy
#    @product_reference = ProductReference.find(params[:id])
#    if @product_reference.can_be_destroyed?
#      @product_reference.destroy
#    else
#      @product_reference.enable = false
#      @product_reference.counter_update("disable_or_before_update")
#      @product_reference.save
#    end
#    
#    flash[:notice] = 'La référence a été supprimée' 
#    redirect_to :controller => 'product_reference_manager', :action => 'index'
#  end
  
  def auto_complete_for_product_reference_reference
    #OPTMIZE use one sql request instead of multiple requests (using has_search_index once it will be improved to accept by_values requests)
    
    keywords = params[:product_reference][:reference].split(" ").collect(&:strip)
    @items = []
    keywords.each do |keyword|
      result = ProductReference.search_with( { 'reference' => keyword, 'name' => keyword, 'description' => keyword, 'product_reference_category.name' => keyword, 'product_reference_category.parent.name' => keyword, :search_type => :or })
      @items = @items.empty? ? result : @items & result
    end
    
    render :partial => 'shared/search_product_reference_auto_complete', :object => @items, :locals => { :fields => "reference designation", :keywords => keywords }
  end
  
end
