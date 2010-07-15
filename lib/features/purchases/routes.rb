ActionController::Routing::Routes.add_routes do |map|

  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel 'cancel', :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form 'cancel_form', :action => "cancel_form", :controller => "purchase_requests" 
  end
  
  map.prepare_for_new 'prepare_for_new' , :controller => 'purchase_orders', :action => 'prepare_for_new'
  
  map.get_supply 'get_supply',  :controller => 'purchase_orders', 
                                    :action => 'get_supply', 
                                    :method => :get
                                      
  map.get_request_supply 'get_request_supply',  :controller => 'purchase_requests', 
                                    :action => 'get_request_supply', 
                                    :method => :get
                                    
  map.auto_complete_for_supply_reference 'auto_complete_for_supply_reference',  :controller => 'purchase_orders', 
                                                                                    :action => 'auto_complete_for_supply_reference', 
                                                                                    :method => :get

  map.auto_complete_for_supplier_name 'auto_complete_for_supplier_name',  :controller => 'purchase_orders', 
                                                                                    :action => 'auto_complete_for_supplier_name', 
                                                                                    :method => :get

  map.resources :purchase_orders do |order|
    order.cancel 'cancel', :controller => 'purchase_orders', :action => 'cancel'
    order.cancel_supply 'cancel_supply/:purchase_order_supply_id', :controller => 'purchase_orders', :action => 'cancel_supply'
    order.cancel_form 'cancel_form', :controller => 'purchase_orders', :action => 'cancel_form'
    order.confirm 'confirm', :controller => 'purchase_orders', :action => 'confirm', :conditions => { :method => :put }
    order.resources :parcels do |parcel|
      parcel.alter_status 'alter_status', :controller => 'parcels', :action => 'alter_status'
      parcel.process_by_supplier_form 'process_by_supplier_form', :controller => 'parcels', :action => 'process_by_supplier_form'
      parcel.process_by_supplier 'process_by_supplier', :controller => 'parcels', :action => 'process_by_supplier'
      parcel.ship_form 'ship_form', :controller => 'parcels', :action => 'ship_form'
      parcel.receive_by_forwarder_form 'receive_by_forwarder_form', :controller => 'parcels', :action => 'receive_by_forwarder_form'
      parcel.receive_form 'receive_form', :controller => 'parcels', :action => 'receive_form'
      parcel.cancel_form 'cancel_form', :controller => 'parcels', :action => 'cancel_form'
      parcel.ship 'process_by_supplier', :controller => 'parcels', :action => "process_by_supplier"
      parcel.ship 'ship', :controller => 'parcels', :action => "ship"
      parcel.receive_by_forwarder 'receive_by_forwarder', :controller => 'parcels', :action => "receive_by_forwarder"
      parcel.receive 'receive', :controller => 'parcels', :action => "receive"
      parcel.cancel 'cancel', :controller => 'parcels', :action => "cancel"
    end
  end
  
  map.resources :purchase_order_supplies do |order_supply|
    order_supply.cancel 'cancel', :controller => 'purchase_order_supplies', :action => 'cancel'
    order_supply.cancel_form 'cancel_form', :controller => 'purchase_order_supplies', :action => 'cancel_form'
  end
  
  map.pending_purchase_orders 'pending_purchase_orders', :controller => 'pending_purchase_orders', :action => 'index'
  map.closed_purchase_orders 'closed_purchase_orders', :controller => 'closed_purchase_orders', :action => 'index'
  
  map.purchases 'purchases', :controller => 'pending_purchase_orders', :action => 'index'  # default page for purchases\

end
