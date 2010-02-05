class OtherToolsController < ApplicationController
  helper :tools, :documents
  
  # GET /other_tools
  def index
    @other_tools = OtherTool.all
  end
  
  # GET /other_tools/:id
  def show
    @other_tool        = OtherTool.find(params[:id])
    @effectives_events = @other_tool.tool_events.effectives.last_three
    @scheduled_events  = @other_tool.tool_events.scheduled.last_three
  end
  
  # GET /other_tools/new
  def new
    @other_tool = OtherTool.new
  end  
  
  # POST /other_tools
  def create
    @other_tool = OtherTool.new(params[:other_tool])
    
    if @other_tool.save
      flash[:notice] = "Equipement ajouté avec succés"
      redirect_to other_tool_path(@other_tool)
    else
      render :action => :new
    end
  end
  
  # GET /other_tools/:id/edit
  def edit
    @other_tool = OtherTool.find(params[:id])
  end
  
  # PUT /other_tools/:id
  def update
    @other_tool = OtherTool.find(params[:id])
    
    if @other_tool.update_attributes(params[:other_tool])
      flash[:notice] = "Equipement modifié avec succés"
      redirect_to other_tool_path(@other_tool)
    else
      render :action => :edit
    end
  end
  
  # DELETE /other_tools/:id
  def destroy
    @other_tool = OtherTool.find(params[:id])
    if @other_tool.destroy
      redirect_to other_tools_path
    else
      flash[:error] = "Erreur lors de la suppression de l'équipment"
    end
  end
   
end
