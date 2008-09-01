class EventsController < ActionController::Base
  helper :all
  
  before_filter :check
  
  def index
    @calendar = Calendar.find(params[:calendar_id])
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    case params[:period]
    when "day"
      @start_date = @date
      @events = [@calendar.events_at_date(@start_date)]
    when "week"
      @start_date = @date.beginning_of_week
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_week)
    when "month"
      @start_date = @date.beginning_of_month
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_month)
    end
    
    @period = params[:period]
    respond_to do |format|
      format.js
    end
  end
  
  def show
    @calendar = Calendar.find(params[:calendar_id])
    @event = Event.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
  
  def new
    @calendar = Calendar.find(params[:calendar_id])
    @event = Event.new
    @event.title = "Nouvel événement"
    @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
    @event.end_at = @event.start_at + (params[:height].to_i).minutes
    respond_to do |format|
      format.js
    end
  end
  
  def edit
    @calendar = Calendar.find(params[:calendar_id])
    @event = Event.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @calendar = Calendar.find(params[:calendar_id])
    params[:event][:by_day] = [params[:event].delete(:by_month_day_num) + params[:event].delete(:by_month_day_wday)] if params[:event][:by_month_day_num] && params[:event][:by_month_day_wday]
    @event = Event.create(params[:event])
    @calendar.events << @event
    respond_to do |format|
      format.js
    end   
  end

  def update
    @event = Event.find(params[:id])
    if params[:event]
      params[:event][:by_day] = [params[:event].delete(:by_day_num) + params[:event].delete(:by_day_wday)] if params[:event][:by_day_num] && params[:event][:by_day_wday]
      [:until_date, :count, :by_day, :by_month_day, :by_month].each do |key|
        params[:event][key] ||= nil
      end
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
      format.js
    end
  end
  
  protected
  
  def check
    # TODO Verify if the current user have the authorization on the calendar and event
  end
end