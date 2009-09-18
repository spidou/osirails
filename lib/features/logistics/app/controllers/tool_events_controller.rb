class ToolEventsController < ApplicationController
  helper :tools, :documents
  
  before_filter :retrieve_tool
  before_filter :prepare_params, :only => [:update,:create]
  
  # GET /tools/:tool_id/tool_events
  def index
    @paginate_tool_events   = @tool.tool_events.paginate(:page => params[:page], :per_page => ToolEvent::TOOL_EVENTS_PER_PAGE)
    @effectives_tool_events = @tool.tool_events.effectives
    @currents_tool_events   = @tool.tool_events.currents
  end
  
  # GET /tools/:tool_id/tool_events/:id
  def show
    @tool_event = ToolEvent.find(params[:id])
  end
  
  # GET /tools/:tool_id/tool_events/new
  def new
    if @tool.can_be_edited?
      @tool_event = @tool.tool_events.build
      @tool_event.build_event
    else
      error_access_page(403)
    end
  end
  
  # POST /tools/:tool_id/tool_events
  def create
    if @tool.can_be_edited?
      @tool_event = @tool.tool_events.build(@prepared_params[:tool_event])
    
      if @tool_event.save
        flash[:notice] = "Évènement ajouté avec succès"
        redirect_to send("#{@tool.class.to_s.tableize.singularize}_path", @tool)
      else
        render :action => :new
      end
    else
      error_access_page(422)
    end
  end
  
  # GET /tools/:tool_id/tool_events/:id/edit
  def edit
    if @tool.can_be_edited?
      @tool_event = ToolEvent.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  # PUT /tools/:tool_id/tool_events/:id
  def update
    if @tool.can_be_edited?
      @tool_event = ToolEvent.find(params[:id])

      if @tool_event.update_attributes(@prepared_params[:tool_event])
        flash[:notice] = "Évènement modifiée avec succès"
        redirect_to send("#{@tool.class.to_s.tableize.singularize}_path", @tool)
      else
        render :action => :edit
      end
    else
      error_access_page(422)
    end
  end
  
  # DELETE /tools/:tool_id/tool_events/:id
  def destroy
    if @tool.can_be_edited?
      @tool_event = ToolEvent.find(params[:id])
      
      unless @tool_event.destroy
        flash[:error] = "Une erreur est survenue lors de la suppression de l'évènement"
      end
      
      redirect_to :back
    else
      error_access_page(422)
    end
  end
  
  private
    
    # OPTIMIZE The subclasses should be retrieved in a dynamic way
    def retrieve_tool
      foreign_keys = ['computer_id','device_id','other_tool_id','machine_id','vehicle_id']
      key          = params.keys.select{|e| foreign_keys.include?(e)}.last.to_sym
      @tool        = Tool.find(params[key])
    end
    
    # TODO manage the delay_type to convert correctly the duration 
    # when the bug with date select and fields_for will be corrected
    #
    def prepare_params
      if params[:alarm].nil? or params[:tool_event][:event_type] == ToolEvent::INCIDENT
        @prepared_params = params
      else
        params[:tool_event][:alarm_attributes] = []
        params[:alarm].each do |alarm|
          raise 'wrong argument #{alarm[:duration_unit]}' unless Alarm::DELAY_UNIT.include?(alarm[:duration_unit])
          
          alarm_param = alarm.reject {|key,v| key == 'duration_unit'}        
          alarm_param[:do_alarm_before] = alarm[:do_alarm_before].to_i.send(alarm[:duration_unit]).to_i
          params[:tool_event][:alarm_attributes] << alarm_param
        end
        @prepared_params = params
      end
    end
end
