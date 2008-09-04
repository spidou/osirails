class CalendarsController < ApplicationController
  before_filter :check_date
  before_filter :check_permissions
  
  def index
    render :action => 'show' 
  end
  
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  protected
    def check_date
      @calendar = current_user.calendar || Calendar.find(params[:id])
      params[:period] = "week" if params[:period].nil?
      unless ["day", "week", "month"].include?(params[:period].downcase)
        params[:period] = "week"
        flash[:error] = "La période demander est invalide"
      end
      begin
      @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      rescue Exception => e
        if params[:year] && params[:month] && params[:day]
          flash[:error] = "Date incorrecte"        
        end
        @date = Date::today
        params[:year] = @date.year
        params[:month] = @date.month
        params[:day] = @date.day
      end
    end

    def check_permissions
      render :text => "Vous n'avez pas le droit de voir ce calendrier" unless (@calendar.user.nil? || @calendar.user == current_user)
    end
end
