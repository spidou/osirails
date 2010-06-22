ActionController::Routing::Routes.add_routes do |map|
  map.resources :purchase_orders do |order|
  end
  
  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel 'cancel', :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form 'cancel_form', :action => "cancel_form", :controller => "purchase_requests" 
  end
  
  map.purchases 'purchases', :controller => 'purchase_orders', :action => 'index'  # default page for purchases\
  
  map.recup_supplies_by_supplier 'recup_supplies_by_supplier',  :controller => 'purchase_orders', 
                                                                :action => 'recup_supplies_by_supplier', 
                                                                :method => :get
  
  map.prepare_for_new 'prepare_for_new' , :controller => 'purchase_orders', :action => 'prepare_for_new'
  
  map.recup_supply 'recup_supply',  :controller => 'purchase_orders', 
                                    :action => 'recup_supply', 
                                    :method => :get
                                      
  map.auto_complete_for_supply_reference 'auto_complete_for_supply_reference',  :controller => 'purchase_orders', 
                                                                                    :action => 'auto_complete_for_supply_reference', 
                                                                                    :method => :get

  map.auto_complete_for_supplier_name 'auto_complete_for_supplier_name',  :controller => 'purchase_orders', 
                                                                                    :action => 'auto_complete_for_supplier_name', 
                                                                                    :method => :get
end
