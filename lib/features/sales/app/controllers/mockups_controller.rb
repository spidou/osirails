class MockupsController < ApplicationController
  acts_as_step_controller :sham => true
  
  helper :graphic_items
  
  before_filter :find_order_end_products, :only => [ :new, :create, :edit, :update ]
  
  # GET /orders/:order_id/mockups
  def index
    @enabled_mockups = @order.mockups.find(:all, :conditions => ["cancelled is NULL or cancelled=false"])
  end  
  
  # GET /orders/:order_id/mockups/:id
  def show
    @mockup = Mockup.find(params[:id])
    @graphic_item_versions = @mockup.graphic_item_versions
  end
  
  # GET /orders/:order_id/mockups/new
  def new
    @mockup = @order.mockups.build
    @mockup.creator = current_user
    @graphic_item_types = MockupType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)
  end
  
  # POST /orders/:order_id/mockups
  def create
    @mockup = @order.mockups.build(params[:mockup])
    @mockup.creator = current_user
    
    @graphic_item_types = MockupType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)  

    if @mockup.save
      flash[:notice] = "La maquette a été créée avec succès."
      redirect_to order_mockups_path
    else
      render :action => "new"
    end
  end
  
  # GET /orders/:order_id/mockups/:id/edit
  def edit
    @mockup = Mockup.find(params[:id])
    @graphic_item_types = MockupType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @mockup.id})
  end
  
  # PUT /orders/:order_id/mockups/:id/update
  def update
    @mockup = Mockup.find(params[:id])  
    @graphic_item_types = MockupType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @mockup.id})

    if @mockup.update_attributes params[:mockup]
      flash[:notice] = "La maquette a été modifiée avec succès."
      redirect_to order_mockup_path
    else
      render :action => "edit"
    end
  end
  
  # GET /orders/:order_id/mockups/:id/cancel
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
  
  # DELETE /orders/:order_id/mockups/:id
  def destroy
    @mockup = Mockup.find(params[:id])
    unless @mockup.destroy
      flash[:error] = "Une erreur est survenue à la suppression de la maquette"
    end
    redirect_to order_mockups_path
  end
  
  # GET /orders/:order_id/mockups/:mockup_id/add_to_spool
  def add_to_spool
    mockup = Mockup.find(params[:mockup_id])
    unless mockup.add_to_graphic_item_spool(params[:file_type],current_user)
      flash[:error] = "Une erreur est survenue à l'ajout du fichier de la file d'attente"
    end
    @spool = GraphicItemSpoolItem.find(:all,:conditions => ["user_id = ?",current_user.id], :order => "created_at DESC")
    redirect_to :action => :index unless request.xhr?
  end
  
  # GET /orders/:order_id/mockups/:mockup_id/remove_from_spool
  def remove_from_spool
    mockup = Mockup.find(params[:mockup_id])
    unless mockup.remove_from_graphic_item_spool(params[:file_type],current_user)
      flash[:error] = "Une erreur est survenue au retrait du fichier de la file d'attente"
    end
    @spool = GraphicItemSpoolItem.find(:all,:conditions => ["user_id = ?",current_user.id], :order => "created_at DESC")
    redirect_to :action => :index unless request.xhr?
  end
  
  private
    def find_order_end_products
      @end_products = @order.end_products
    end
end
