class ToolEventsController < ApplicationController
  helper :tools, :documents
  before_filter :retrieve_tool
  
  # GET /tools/:tool_id/tool_events
  def index
    @paginate_events = @tool.tool_events.all(:order => 'start_date DESC').paginate(:page => params[:page], :per_page => 5)
    @effectives_events = @tool.tool_events.effectives.all(:order => 'start_date DESC')
  end
  
  # GET /tools/:tool_id/tool_events/:id
  def show
    @event = ToolEvent.find params[:id]
  end
  
  # GET /tools/:tool_id/tool_events/new
  def new
    @event = @tool.tool_events.build
  end
  
  # POST /tools/:tool_id/tool_events
  def create
    @event = @tool.tool_events.build(params[:tool_event])
    
    if @event.save
      flash[:notice] = "Intervention Ajoutée avec succés"
      redirect_to send "#{@tool.class.to_s.tableize.singularize}_path", @tool
    else
      render :action => :new
    end
  end
  
  # GET /tools/:tool_id/tool_events/:id/edit
  def edit
    @event = ToolEvent.find params[:id]
  end
  
  # PUT /tools/:tool_id/tool_events/:id
  def update
    @event = ToolEvent.find params[:id]
    
    if @event.update_attributes(params[:tool_event])
      flash[:notice] = "Intervention modifiée avec succés"
      redirect_to send "#{@tool.class.to_s.tableize.singularize}_path", @tool
    else
      render :action => :edit
    end
  end
  
  # DELETE /tools/:tool_id/tool_events/:id
  def destroy
    ToolEvent.find(params[:id]).destroy
    redirect_to :back
  end
  
  private
    
    # OPTIMIZE The subclasses should be retrieved in a dynamic way
    def retrieve_tool
      foreign_keys = ['computer_id','device_id','other_tool_id','machine_id','vehicule_id']
      key          = params.keys.select{|e| foreign_keys.include?(e)}.last.to_sym
      @tool        = Tool.find params[key]
    end
end
