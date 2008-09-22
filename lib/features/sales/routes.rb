ActionController::Routing::Routes.add_routes do |map|
  # TODO enlever les map.connect pour les remplacer par des sous ressources d'order
  #map.connect 'orders/new', :controller => 'commercial', :action => 'new'
  #map.connect 'orders/:id/commercial/:action', :controller => 'commercial'
  #map.connect 'orders/:id/commercial/survey/:action', :controller => 'survey'
  #map.connect 'orders/:id/commercial/graphic_conception/:action', :controller => 'graphic_conception'
  #map.connect 'orders/:id/commercial/estimate/:action', :controller => 'estimate'
  #map.connect 'orders/:id/invoicing/:action', :controller => 'invoicing'
  
  #map.resources :orders do |order|
  #  order.resources :commercial
  #  order.resources :survey
  #  order.resources :graphic_conception
  #  order.resources :estimate
  #  order.resources :invoicing
  #end

  map.resources :orders
  map.connect 'orders/:id/:step', :controller => 'orders', :action => 'show'
  map.connect 'orders/:id/:step/edit', :controller => 'orders', :action => 'edit'
  
  map.prospectives 'prospectives', :controller => 'commercial', :action => 'index'
  map.sales 'sales', :controller => 'invoicing', :action => 'index'
end