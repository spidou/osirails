class CalendarsController < ActionController::Base
  layout 'default'
  helper :all
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
    if params[:year] && params[:month] && params[:day]
      @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      @date = Date::today
    end
  end
    
  def get_events
    @calendar = Calendar.find(params[:id])
    if params[:year] && params[:month] && params[:day]
      @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      @date = Date::today
    end
    
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

  def update
    @event = Event.find(params[:id])
    @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
    @event.end_at = @event.start_at + (params[:height].to_i).minutes 
    if @event.save
      render :text => "true"
    else
      render :text => "false"
    end
  end
end
