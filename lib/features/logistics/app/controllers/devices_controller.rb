class DevicesController < ApplicationController
  helper :tools, :documents
  
  # GET /devices
  def index
    @devices = Device.all
  end
  
  # GET /devices/:id
  def show
    @device                   = Device.find params[:id]
    @effectives_events = @device.tool_events.desc.effectives.all(:limit => 3, :order => "start_date DESC") 
    @scheduled_events  = @device.tool_events.desc.scheduled.all(:limit => 3, :order => "start_date DESC")
  end
  
  # GET /devices/new
  def new
    @device = Device.new
  end  
  
  # POST /devices
  def create
    @device = Device.new params[:device]
    
    if @device.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to device_path(@device)
    else
      render :action => :new
    end
  end
  
  # GET /devices/:id/edit
  def edit
    @device = Device.find params[:id]
  end
  
  # PUT /devices/:id
  def update
    @device = Device.find params[:id]
    
    if @device.update_attributes params[:device]
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to device_path(@device)
    else
      render :action => :edit
    end
  end
  
  # DELETE /devices/:id
  def destroy
    @device = Device.find params[:id]
    if @device.destroy
      redirect_to devices_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
