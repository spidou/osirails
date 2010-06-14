ActionController::Routing::Routes.add_routes do |map|
  map.resources :purchase_orders
  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel 'cancel', :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form 'cancel_form', :action => "cancel_form", :controller => "purchase_requests" 
  end
  map.resources :order_supplies
  map.resources :request_supplies
  map.purchases 'purchases', :controller => 'purchase_orders', :action => 'index'  # default page for purchases\
end
