class VehiculesController < ApplicationController
  helper :tools, :documents
  
  # GET /vehicules
  def index
    @vehicules = Vehicule.all
  end
  
  # GET /vehicules/:id
  def show
    @vehicule                 = Vehicule.find params[:id]
    @effectives_events = @vehicule.tool_events.desc.effectives.all(:limit => 3, :order => "start_date DESC") 
    @scheduled_events  = @vehicule.tool_events.desc.scheduled.all(:limit => 3, :order => "start_date DESC")
  end
  
  # GET /vehicules/new
  def new
    @vehicule = Vehicule.new
  end  
  
  # POST /vehicules
  def create
    @vehicule = Vehicule.new params[:vehicule]
    
    if @vehicule.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to vehicule_path(@vehicule)
    else
      render :action => :new
    end
  end
  
  # GET /vehicules/:id/edit
  def edit
    @vehicule = Vehicule.find params[:id]
  end
  
  # PUT /vehicules/:id
  def update
    @vehicule = Vehicule.find params[:id]
    
    if @vehicule.update_attributes params[:vehicule]
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to vehicule_path(@vehicule)
    else
      render :action => :edit
    end
  end
  
  # DELETE /vehicules/:id
  def destroy
    @vehicule = Vehicule.find params[:id]
    if @vehicule.destroy
      redirect_to vehicules_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
