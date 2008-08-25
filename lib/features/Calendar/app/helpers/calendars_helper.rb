def get_events_function
  remote_function(:url => {:controller => "calendars", :action => "get_events", :id => params[:id], :period => params[:period], :year => params[:year], :month => params[:month], :day => params[:day]})
end

def render_calendar(period)
  case period
  when "day"
    render :partial => 'day'
  when "week"
    render :partial => 'week'
  when "month"
    render :partial => 'month'
  end
end