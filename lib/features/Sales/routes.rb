ActionController::Routing::Routes.add_routes do |map|
  map.connect 'orders/:id/commercial/:action', :controller => 'commercial'
  map.connect 'orders/:id/survey/:action', :controller => 'survey'
  map.connect 'orders/:id/graphic_conception/:action', :controller => 'graphic_conception'
  map.connect 'orders/:id/estimate/:action', :controller => 'estimate'
  map.connect 'orders/:id/invoicing/:action', :controller => 'invoicing'
end