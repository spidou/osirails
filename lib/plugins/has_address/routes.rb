ActionController::Routing::Routes.add_routes do |map|
  map.auto_complete_for_city_zip_code 'auto_complete_for_city_zip_code', :controller  => 'cities',
                                                                         :action      => 'auto_complete_for_city_zip_code',
                                                                         :method      => :get
                                                                         
  map.auto_complete_for_city_name     'auto_complete_for_city_name',     :controller  => 'cities',
                                                                         :action      => 'auto_complete_for_city_name',
                                                                         :method      => :get
                                                                         
  map.auto_complete_for_region_name   'auto_complete_for_region_name',   :controller  => 'regions',
                                                                         :action      => 'auto_complete_for_region_name',
                                                                         :method      => :get  
                                                                         
  map.auto_complete_for_country_name  'auto_complete_for_country_name',  :controller  => 'countries',
                                                                         :action      => 'auto_complete_for_country_name',
                                                                         :method      => :get  
  
  map.auto_complete_from_city   'auto_complete_from_city',   :controller => 'cities',  :action => 'auto_complete_from_city'
  map.auto_complete_from_region 'auto_complete_from_region', :controller => 'regions', :action => 'auto_complete_from_region'
end
