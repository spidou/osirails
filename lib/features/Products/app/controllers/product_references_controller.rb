class ProductReferencesController < ApplicationController

  # GET /product_references
  def index
    if params[:product_reference_category_id].nil?
      @references = ProductReference.find(:all)
      @type = 'normal'
    else
      @categories = ProductReferenceCategory.find(params[:product_reference_category_id].split(","))
      render :layout => false
    end
  end

  # GET /product_references/new
  def new
    @reference = ProductReference.new(:product_reference_category_id => params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end
  
  # GET /product_reference/1
  def show
    @reference = ProductReference.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render :layout => false}
    end
  end

  # GET /product_references/1/edit
  def edit
    @reference = ProductReference.find(params[:id])
    @categories = ProductReferenceCategory.find(:all)
  end

  
  # POST /product_references
  def create
    @categories = ProductReferenceCategory.find(:all)
    @reference = ProductReference.new(params[:product_reference])
    if @reference.save
      flash[:notice] = "La r&eacute;f&eacute;rence a &eacute;t&eacute; cr&eacute;&eacute;e avec succ&egrave;s"
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # PUT /product_references/1
  def update
    @categories = ProductReferenceCategory.find(:all)
    @reference = ProductReference.find(params[:id])
    @reference.counter_update("disable_or_before_update")
    if @reference.update_attributes(params[:product_reference])
      @reference.counter_update("after_update")
      flash[:notice] = 'La r&eacute;f&eacute;rence a &eacute;t&eacute; mise &agrave; jour'
      redirect_to :controller => 'product_reference_manager', :action => 'index'
    else
      flash[:error] = 'Une erreur est survenue lors de la mise &agrave; jour'
      render :action => 'edit'
    end
  end

  # DELETE /product_references/1
  def destroy
    @reference = ProductReference.find(params[:id])
    if @reference.can_destroy?
      @reference.destroy
    else
      @reference.enable = false
      @reference.counter_update("disable_or_before_update")
      @reference.save
    end
    
    flash[:notice] = 'La r&eacute;f&eacute;rence a &eacute;t&eacute; supprim&eacute;e' 
    redirect_to :controller => 'product_reference_manager', :action => 'index'
  end
  
end
