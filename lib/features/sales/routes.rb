ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders
  map.connect 'orders/:id/:step', :controller => 'orders', :action => 'show'
  map.connect 'orders/:id/:step/edit', :controller => 'orders', :action => 'edit'
  
  map.prospectives 'prospectives', :controller => 'commercial', :action => 'index'
  map.sales 'sales', :controller => 'invoicing', :action => 'index'
end