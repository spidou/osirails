class EventsController < ActionController::Base
  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def new
    
  end
  
  def edit
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    
  end
  
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      @message = "Modification effectué avec succès"
    else
      @message = "Erreur lors de la modification"
    end
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    
  end
end