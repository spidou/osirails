ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    order.resource :commercial
    order.resource :invoicing
  end
  
  map.prospectives "prospective", :controller => 'orders', :action => 'commercial_orders'
  map.sales "sales", :controller => 'orders', :action => 'invoicing_orders'
end