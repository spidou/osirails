class CalendarsController < ActionController::Base
  before_filter :check_date
  layout 'default'
  helper :all
  
  def show
    @calendar = Calendar.find(params[:id])
  end
  
  def get_period
    @calendar = Calendar.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
    
  def get_events
    @calendar = Calendar.find(params[:id])
    
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
  
  protected

  def check_date
    params[:period] = "week" if params[:period].nil?
    unless ["day", "week", "year"].include?(params[:period].downcase)
      params[:period] = "week"  
      flash[:error] = "La période demander est invalide"
    end
    begin
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    rescue ArgumentError
      @date = Date::today
      flash[:error] = "Date incorrecte"
    end
  end
end
