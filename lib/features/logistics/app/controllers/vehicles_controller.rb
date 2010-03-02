class VehiclesController < ApplicationController
  helper :tools, :documents
  
  # GET /vehicles
  def index
    @vehicles = Vehicle.all
  end
  
  # GET /vehicles/:id
  def show
    @vehicle           = Vehicle.find(params[:id])
    @effectives_events = @vehicle.tool_events.effectives.last_three
    @scheduled_events  = @vehicle.tool_events.scheduled.last_three
  end
  
  # GET /vehicles/new
  def new
    @vehicle = Vehicle.new
  end  
  
  # POST /vehicles
  def create
    @vehicle = Vehicle.new(params[:vehicle])
    
    if @vehicle.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to vehicle_path(@vehicle)
    else
      render :action => :new
    end
  end
  
  # GET /vehicles/:id/edit
  def edit
    @vehicle = Vehicle.find(params[:id])
  end
  
  # PUT /vehicles/:id
  def update
    @vehicle = Vehicle.find(params[:id])
    
    if @vehicle.update_attributes(params[:vehicle])
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to vehicle_path(@vehicle)
    else
      render :action => :edit
    end
  end
  
  # DELETE /vehicles/:id
  def destroy
    @vehicle = Vehicle.find(params[:id])
    if @vehicle.destroy
      redirect_to vehicles_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
