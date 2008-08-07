class ProductReferencesController < ApplicationController

  # GET /product_references
  def index
    @categories = ProductReferenceCategory.find( :all, :order => "name" )
    @references = ProductReference.find( :all, :order => "name" , :conditions => { :enable => 1} )
  end

  # GET /product_references/new
  def new
    @category = ProductReferenceCategory.new
    @reference = ProductReference.new
    @categories = ProductReferenceCategory.find(:all)
  end

  # GET /product_references/1/edit
  def edit
    @categories = ProductReferenceCategory.find(:all)
    if params[:type] == 'categorie'
      @category = ProductReferenceCategory.find(params[:id])
    elsif params[:type] == 'reference'
      @reference = ProductReference.find(params[:id])
    end
  end
  
  # POST /product_references
  def create
    if params[:product_reference_category]
      @object = ProductReferenceCategory.new(params[:product_reference_category])
      @type = "Cat&eacute;gorie"
    elsif params[:product_reference]
      @object = ProductReference.new(params[:product_reference])
      @type = "R&eacute;f&eacute;rence"
    end
    if @object and @object.save
      flash[:notice] = @type + " cr&eacute;e avec succ&egrave;s"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # PUT /product_references/1
  def update
    if params[:product_reference_category]
      @category = ProductReferenceCategory.find(params[:id])
      render :action => 'edit'
    elsif params[:product_reference]
      @reference = ProductReference.find(params[:id])
      old_category_id = @reference.product_reference_category_id
      if @reference.update_attributes(params[:product_reference])
        ProductReferenceCategory.update_counters old_category_id, :product_references_count => - 1
        ProductReferenceCategory.update_counters @reference.product_reference_category_id, :product_references_count => 1
        flash[:notice] = 'La r&eacute;f&eacute;rence est bien mis &agrave; jour'
        redirect_to :action => 'index'
      else
        flash[:error] = 'Une erreur est survenue dans la mise &agrave; jour'
        render :action => 'edit'
      end
    end
  end

  # DELETE /product_references/1
  def destroy
    
  end
  
end