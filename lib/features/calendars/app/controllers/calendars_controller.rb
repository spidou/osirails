class CalendarsController < ApplicationController
  before_filter :check_date, :check_permissions
  
  def index
    render :action => 'show' 
  end
  
  # GET /calendars/:id_or_name/:period/:year/:month/:day
  #
  # ==== Examples :
  # /calendars/1
  # /calendars/1/month
  # /calendars/1/month/2009/01/01
  #
  # /calendars/calendar_name
  # /calendars/calendar_name/week
  # /calendars/calendar_name/week/2009/01/01
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def auto_complete_for_event_participants
    value = params[:participants][:text]
    @contacts = []
    if @calendar.id.nil?
      all_contacts = Employee.all + Contacts.find.all
    else
      all_contacts = Employee.all + (@calendar.user.employee.nil? ? [] : @calendar.user.employee.contacts)
    end

    all_contacts.each do |contact|
      if @contacts.size < 10
        if contact.last_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << contact 
        end
        if contact.first_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << contact
        end
        if contact.email.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << contact
        end
      end
    end
    @contacts = @contacts.uniq
    render :partial => 'autocomplete'
  end
   
  protected
    def check_date
      if params[:id_or_name]
        begin
          if params[:id_or_name].to_i > 0
            @calendar = Calendar.find(params[:id_or_name])
          else
            @calendar = Calendar.find_by_name(params[:id_or_name])
          end
        rescue
          error_access_page(404)
        end
      else
        @calendar = current_user.calendar
      end
      
      params[:period] ||= "week"
      
      today = Date.today
      params[:year] ||= today.year
      params[:month] ||= today.month
      params[:day] ||= today.day
      
      begin
        @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      rescue ArgumentError => e
        raise ActionController::RoutingError, e.message
      rescue Exception => e
        error_access_page(500)
      end
    end

    def check_permissions
      if @calendar.user
        error_access_page(403) unless @calendar.user == current_user
      else
        error_access_page(403) unless @calendar.can_view?(current_user)
      end
    end
end
