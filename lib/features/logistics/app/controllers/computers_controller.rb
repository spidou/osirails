class ComputersController < ApplicationController
  helper :tools, :documents
  
  # GET /computers
  def index
    @computers = Computer.all
  end
  
  # GET /computers/:id
  def show
    @computer          = Computer.find params[:id]
    @effectives_events = @computer.tool_events.desc.effectives.all(:limit => 3, :order => "start_date DESC") 
    @scheduled_events  = @computer.tool_events.desc.scheduled.all(:limit => 3, :order => "start_date DESC")
  end
  
  # GET /computers/new
  def new
    @computer = Computer.new
  end  
  
  # POST /computers
  def create
    @computer = Computer.new params[:computer]
    
    if @computer.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to computer_path(@computer)
    else
      render :action => :new
    end
  end
  
  # GET /computers/:id/edit
  def edit
    @computer = Computer.find params[:id]
  end
  
  # PUT /computers/:id
  def update
    @computer = Computer.find params[:id]
    
    if @computer.update_attributes params[:computer]
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to computer_path(@computer)
    else
      render :action => :edit
    end
  end
  
  # DELETE /computers/:id
  def destroy
    @computer = Computer.find params[:id]
    if @computer.destroy
      redirect_to computers_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
