ActionController::Routing::Routes.add_routes do |map|
  map.resources :customers do |customer|
    customer.resources :establishments
    customer.resources :contacts # Customer don't call has_contacts, but it has contacts via its establishments
  end
  
  map.resources :suppliers
  
  map.resources :factors
  
  map.thirds 'thirds', :controller => 'customers' #default page for thirds
end
