class CalendarsController < ActionController::Base
  $month_fr ||= []
  $month_fr << "Janvier"
  $month_fr << "Février"
  $month_fr << "Mars"
  $month_fr << "Avril"
  $month_fr << "Mai"
  $month_fr << "Juin"
  $month_fr << "Juillet"
  $month_fr << "Août"
  $month_fr << "Septembre"
  $month_fr << "Octobre"
  $month_fr << "Novembre"
  $month_fr << "Décembre"
  $day_fr ||= []
  $day_fr << "Dimanche"
  $day_fr << "Lundi"
  $day_fr << "Mardi"
  $day_fr << "Mercredi"
  $day_fr << "Jeudi"
  $day_fr << "Vendredi"
  $day_fr << "Samedi"
  
  def show
    @calendar = Calendar.find(params[:id])
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
  
  def edit
    @event = Event.find(params[:event_id] || :first)
  end
  
  def get_events
    @calendar = Calendar.find(params[:id])
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    case params[:period]
    when "day"
      @start_date = @date
      @events = @calendar.events_at_period(:start_date => @start_date)
    when "week"
      @start_date = @date.beginning_of_week
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_week)
    when "month"
      @start_date = @date.beginning_of_month
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_month)
    else
      @events = @calendar.events_at_date(Date::today)
    end
    
    @period = params[:period]
    respond_to do |format|
      format.js
    end
  end
  
  def update
    @event = Event.find(params[:id])
    case params[:period]
    when "day"
      start_period = @event.start_at.beginning_of_day
    when "week"
      start_period = @event.start_at.beginning_of_week
    when "month"
      start_period = @event.start_at.beginning_of_month
    else
      raise "Invalid period"
    end
    @event.start_at = start_period + params[:wday].to_i.days + params[:top].to_i.minutes
    @event.end_at = @event.start_at + (params[:height].to_i).minutes 
    if @event.save
      render :text => "true"
    else
      render :text => "false"
    end
  end
end
