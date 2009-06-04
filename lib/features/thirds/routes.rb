ActionController::Routing::Routes.add_routes do |map|
  map.resources :customers do |customer|
    customer.resources :establishments
  end
  
  map.resources :suppliers
  
  map.thirds 'thirds', :controller => 'customers' #default page for thirds
end
