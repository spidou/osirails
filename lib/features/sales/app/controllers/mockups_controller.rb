class MockupsController < ApplicationController
  acts_as_step_controller :sham => true
  helper :graphic_items
  
  # GET /orders/[:order_id]/mockups
  def index
    @employee = current_user.employee
    @enabled_mockups = @order.mockups.find(:all,:conditions => {:cancelled => false})
  end  
  
  # GET /orders/[:order_id]/mockups/:id
  def show
    @employee = current_user.employee
    @mockup = Mockup.find(params[:id])
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @mockup.id})
  end
  
  # GET /orders/[:order_id]/mockups/new
  def new
    @mockup = @order.mockups.build
    @products = @order.products
    @graphic_item_types = MockupType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)
  end
  
  # POST /orders/[:order_id]/mockups
  def create
    @mockup = @order.mockups.build(params[:mockup])
    @mockup.creator = current_user.employee
    
    @products = @order.products
    @graphic_item_types = MockupType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)  

    if @mockup.save
      flash[:notice] = "La maquette a été créée avec succès."
      redirect_to order_mockups_path
    else
      render :action => "new"
    end
  end
  
  # GET /orders/[:order_id]/mockups/:id/edit
  def edit
    @mockup = Mockup.find(params[:id])
    @products = @order.products
    @graphic_item_types = MockupType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @mockup.id})
  end
  
  # PUT /orders/[:order_id]/mockups/:id/update
  def update
    @mockup = Mockup.find(params[:id])  
    @products = @order.products
    @graphic_item_types = MockupType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @mockup.id})

    if @mockup.update_attributes params[:mockup]
      flash[:notice] = "La maquette a été modifiée avec succès."
      redirect_to order_mockup_path
    else
      render :action => "edit"
    end
  end
  
  # GET /orders/[:order_id]/mockups/:id/cancel
  def cancel
    @mockup = Mockup.find(params[:mockup_id])    
    if @mockup.can_be_cancelled?
      unless @mockup.cancel
        flash[:error] = "Une erreur est survenue à la désactivation de la maquette"
      end
      redirect_to order_mockups_path
    else
      error_access_page(403)
    end
  end
  
  # DELETE /orders/[:order_id]/mockups/:id
  def destroy
    @mockup = Mockup.find(params[:id])
    unless @mockup.destroy
      flash[:error] = "Une erreur est survenue à la suppression de la maquette"
    end
    redirect_to order_mockups_path
  end
end
