ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    order.resource 'commercial', :controller => 'commercial'
    order.resources 'estimates', :controller => 'estimate'
    order.resource 'graphic_conception', :controller => 'graphic_conception'
    order.resource 'informations', :controller => 'informations'
    order.resource 'invoicing', :controller => 'invoicing'
    order.resource 'survey', :controller => 'survey' do |survey|
      survey.resources :documents
    end
    
    order.resource 'logs', :controller => 'logs'
  end
  
  #map.connect 'orders/:id/:step', :controller => 'orders', :action => 'show'
  #map.connect 'orders/:id/:step/edit', :controller => 'orders', :action => 'edit'
  #map.connect 'orders/:id/:step/', :controller => 'orders', :action => 'update', :method => 'put'
  
  map.prospectives 'prospectives', :controller => 'commercial', :action => 'index'
  map.sales 'sales', :controller => 'invoicing', :action => 'index'
end