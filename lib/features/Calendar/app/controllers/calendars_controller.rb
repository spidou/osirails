class CalendarsController < ActionController::Base
  before_filter :check_date
  layout 'default'
  helper :all
  
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  protected

  def check_date
    @calendar = Calendar.find(params[:id])
    params[:period] = "week" if params[:period].nil?
    unless ["day", "week", "month"].include?(params[:period].downcase)
      params[:period] = "week"
      flash[:error] = "La période demander est invalide"
    end
    begin
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    rescue Exception => e
      @date = Date::today
      params[:year] = @date.year
      params[:month] = @date.month
      params[:day] = @date.day
      flash[:error] = "Date incorrecte"
    end
  end
end
