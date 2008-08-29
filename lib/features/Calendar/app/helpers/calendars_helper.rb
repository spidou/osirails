module CalendarsHelper
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
  
  def navigation_before(date)
    case params[:period]
    when 'day'
      date_before = date - 1.day
    when 'week'
      date_before = date - 1.week
    when 'month'
      date_before = date - 1.month      
    end
    calendar_path(@calendar, :period => params[:period], :year => date_before.year, :month => date_before.month, :day => date_before.day)
  end
  
  def navigation_after(date)
    case params[:period]
    when 'day'
      date_after = date + 1.day
    when 'week'
      date_after = date + 1.week
    when 'month'
      date_after = date + 1.month     
    end
    calendar_path(@calendar, :period => params[:period], :year => date_after.year, :month => date_after.month, :day => date_after.day)
  end
  
  def navigation(period)
    calendar_path(@calendar, :period => params[:period], :year => params[:year], :month => params[:month], :day => params[:day])
  end
  
  def get_events_link
    calendar_events_path(@calendar, :period => params[:period], :year => params[:year], :month => params[:month], :day => params[:day])
  end
end