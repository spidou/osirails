def get_events_function
  remote_function :url => {:action => "get_events", :id => params[:id],  :period => params[:period], :year => params[:year], :month => params[:month], :day => params[:day]}
end