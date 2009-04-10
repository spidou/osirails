ActionController::Routing::Routes.add_routes do |map|
  map.resources :calendars do |calendar|
    calendar.resources :events
  end
  map.connect 'calendars/auto_complete_for_event_participants/:id', :controller => 'calendars',
                                                                    :action => 'auto_complete_for_event_participants'
  map.my_calendar 'calendars/:id/:period/:year/:month/:day', :controller => 'calendars',
                                                             :action => 'show',
                                                             :id => nil,
                                                             :period => nil,
                                                             :year => nil,
                                                             :month => nil,
                                                             :day => nil,
                                                             :requirements => {
                                                               :period => /(day|week|month)/,
                                                               :year => /(19|20)\d\d/,
                                                               :month => /([1-9]|1[012])/,
                                                               :day => /([1-9]|[1|2]\d|3[01])/
                                                             }
end
