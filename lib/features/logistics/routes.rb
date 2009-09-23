ActionController::Routing::Routes.add_routes do |map|
  map.resources :commodities
  map.refresh_measure_commodity 'commodities/refresh_measure', :controller => 'commodities', :action => 'refresh_measure'
  map.resources :commodity_categories
  map.commodities_manager "commodities_manager", :controller => "commodities_manager"
  map.logistics 'logistics', :controller => 'commodities_manager' #default page for products
  map.resources :inventories
  map.resources :commodities_inventories
  map.resources :tools

  [:computers, :devices, :machines, :vehicles, :other_tools].each do |tool_type|
    map.resources tool_type do |tool|
      tool.resources :tool_events
    end
  end
  
  map.equipments_calendar 'equipments_calendar/:id_or_name/:period/:year/:month/:day',
                          :controller   => 'equipments_calendar',
                          :action       => 'show',
                          :id_or_name   => 'equipments_calendar',
                          :period       => 'month',
                          :year         => nil,
                          :month        => nil,
                          :day          => nil,
                          :requirements => {
                            :period => /(day|week|month)/,
                            :year   => /(19|20)\d\d/,
                            :month  => /(0?[1-9]|1[012])/,
                            :day    => /(0?[1-9]|[1|2]\d|3[01])/
                          }
  
end
