class MachinesController < ApplicationController
  helper :tools, :documents
    
  # GET /machines
  def index
    @machines = Machine.all
  end
  
  # GET /machines/:id
  def show
    @machine           = Machine.find(params[:id])
    @effectives_events = @machine.tool_events.effectives.last_three
    @scheduled_events  = @machine.tool_events.scheduled.last_three
  end
  
  # GET /machines/new
  def new
    @machine = Machine.new
  end  
  
  # POST /machines
  def create
    @machine = Machine.new(params[:machine])
    
    if @machine.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to machine_path(@machine)
    else
      render :action => :new
    end
  end
  
  # GET /machines/:id/edit
  def edit
    @machine = Machine.find(params[:id])
  end
  
  # PUT /machines/:id
  def update
    @machine = Machine.find(params[:id])
    
    if @machine.update_attributes(params[:machine])
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to machine_path(@machine)
    else
      render :action => :edit
    end
  end
  
  # DELETE /machines/:id
  def destroy
    @machine = Machine.find(params[:id])
    if @machine.destroy
      redirect_to machines_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
