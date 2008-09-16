ActionController::Routing::Routes.add_routes do |map|
  map.resources :calendars do |calendar|
    calendar.resources :events
  end
  map.connect 'calendars/auto_complete_for_event_participants/:id', :controller => 'calendars', :action => 'auto_complete_for_event_participants'
  map.connect 'calendars/:id/:period/:year/:month/:day', :controller => 'calendars', :action => 'show', :period => nil, :year => nil, :month => nil, :day => nil
end