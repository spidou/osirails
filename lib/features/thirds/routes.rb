ActionController::Routing::Routes.add_routes do |map|
  map.resources :customers do |customer|
    customer.resources :contacts
    customer.resources :establishments do |establishment|
      establishment.resources :contacts
    end
  end
  
  map.resources :suppliers do |supplier|
    supplier.resources :contacts
  end
  map.connect 'thirds', :controller => 'customers' #default page for thirds
end