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
      @calendar = Calendar.find(params[:id] || current_user.calendar)
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
