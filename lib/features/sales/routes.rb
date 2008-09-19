ActionController::Routing::Routes.add_routes do |map|
  map.connect 'orders/:id/commercial/:action', :controller => 'commercial'
  map.connect 'orders/:id/commercial/survey/:action', :controller => 'survey'
  map.connect 'orders/:id/commercial/graphic_conception/:action', :controller => 'graphic_conception'
  map.connect 'orders/:id/commercial/estimate/:action', :controller => 'estimate'
  map.connect 'orders/:id/invoicing/:action', :controller => 'invoicing'
  
  map.prospectives 'prospective', :controller => 'commercial'
  map.sales 'sales', :controller => 'invoicing'
end