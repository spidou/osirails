class EventsController < ActionController::Base
  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      #format.html
      format.js
    end
  end
  
  def new
    @event = Event.new
    @event.title = "Nouvel événement"
    @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
    @event.end_at = @event.start_at + (params[:height].to_i).minutes
    respond_to do |format|
      #format.html
      format.js
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    respond_to do |format|
      #format.html
      format.js
    end
  end
  
  def create
    @event = Event.create(params[:event])
    respond_to do |format|
      format.js
    end   
  end

  def update
    @event = Event.find(params[:id])
    if params[:event]
      if @event.update_attributes(params[:event])
        @message = "Modification effectué avec succès"
      else
        @message = "Erreur lors de la modification"
      end
      respond_to do |format|
        format.js
      end
    else
      @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
      @event.end_at = @event.start_at + (params[:height].to_i).minutes 
      if @event.save
        render :text => "true"
      else
        render :text => "false"
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    respond_to do |format|
      #format.html { redirect_to :back }
      format.js
    end
  end
end