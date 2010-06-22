ActionController::Routing::Routes.add_routes do |map|
  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel 'cancel', :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form 'cancel_form', :action => "cancel_form", :controller => "purchase_requests" 
  end
  
  map.resources :purchase_orders do |order|
    order.cancel 'cancel', :controller => 'purchase_orders', :action => 'cancel'
  end
  map.pending_purchase_orders 'pending_purchase_orders', :controller => 'pending_purchase_orders', :action => 'index'
  map.closed_purchase_orders 'closed_purchase_orders', :controller => 'closed_purchase_orders', :action => 'index'
  
  map.purchases 'purchases', :controller => 'pending_purchase_orders', :action => 'index'  # default page for purchases\
end
