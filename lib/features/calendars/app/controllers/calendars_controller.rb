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
  
  def auto_complete_for_event_participants
    value = params[:participants][:text]
    @contacts = []
    if @calendar.id.nil?
      all_contacts = Employee.find(:all) + Contacts.find(:all)
    else
      all_contacts = Employee.find(:all) + (@calendar.user.employee.nil? ? [] : @calendar.user.employee.contacts)
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
      calendar_id = params[:id] || current_user.calendar
      params[:period] ||= "week"
      
      today = Date.today
      params[:year] ||= today.year
      params[:month] ||= today.month
      params[:day] ||= today.day
      
      @calendar = Calendar.find(calendar_id)
      begin
        @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      rescue ArgumentError => e
        raise ActionController::RoutingError, e.message
      rescue Exception => e
        error_access_page(500)
      end
    end

    def check_permissions
      error_access_page(403) unless (@calendar.user.nil? || @calendar.user == current_user)
    end
end
