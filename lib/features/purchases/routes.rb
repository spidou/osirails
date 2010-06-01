ActionController::Routing::Routes.add_routes do |map|
  map.resources :purchase_orders
  map.resources :purchase_requests
  map.purchases 'purchases', :controller => 'purchase_orders', :action => 'index'  # default page for purchases\
end
