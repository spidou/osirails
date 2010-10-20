class ForwardersController < ApplicationController

  helper :thirds, :conveyances, :departures

  # GET /forwarders
  def index
    @forwarders = Forwarder.activates.paginate(:page => params[:page], :per_page => Forwarder::FORWARDER_PER_PAGE)
  end
  
  # GET /forwarders/:id
  def show
    @forwarder = Forwarder.find(params[:id])
  end
  
  # GET /forwarders/new
  def new
    @forwarder = Forwarder.new
  end
  
  # GET /forwarders/:forwarder_id/edit
  def edit
    @forwarder = Forwarder.find(params[:id])
  end
  
  # POST /forwarders
  def create
    @forwarder = Forwarder.new(params[:forwarder])
    @forwarder.creator = current_user
    if @forwarder.save
      flash[:notice] = "Transporteur ajouté avec succès"
      redirect_to(forwarder_path(@forwarder))
    else
      render :action => 'new'
    end
  end
  
  # PUT /forwarders/:id
  def update
    @forwarder = Forwarder.find(params[:id])
    if @forwarder.update_attributes(params[:forwarder])
      flash[:notice] = "Le transporteur a été modifié avec succès"
      redirect_to forwarder_path(@forwarder)
    else
      render :action => 'edit'
    end
  end
  
  #GET /forwarders/:forwarder_id/deactivate
  def deactivate
    @forwarder = Forwarder.find(params[:forwarder_id])
    @forwarder.activated = false
    if @forwarder.save
      flash[:notice] = "Le transporteur a été supprimé avec succès"
      redirect_to(forwarders_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du transporteur"
      redirect_to :back
    end
  end

end
