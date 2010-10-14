ActionController::Routing::Routes.add_routes do |map|
  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel        'cancel',       :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form   'cancel_form',  :controller => 'purchase_requests', :action => 'cancel_form'
  end
  
  map.prepare_for_new_quotation_request 'quotation_requests/prepare_for_new', :controller => 'quotation_requests', :action => 'prepare_for_new'
  map.auto_complete_for_supply 'auto_complete_for_supply',  :controller => 'quotation_requests', 
                                                            :action     => 'auto_complete_for_supply', 
                                                            :method     => :post
  map.quotation_request_supply 'quotation_request_supply', :controller => 'quotation_requests',
                                                           :action => 'quotation_request_supply',
                                                           :method => :get
  map.resources :quotation_requests
  
  map.prepare_for_new 'purchase_orders/prepare_for_new', :controller => 'purchase_orders', :action => 'prepare_for_new'
  
  map.purchase_order_supply_in_one_line 'purchase_order_supply_in_one_line',  :controller => 'purchase_orders', 
                                    :action => 'purchase_order_supply_in_one_line', 
                                    :method => :get
  
  map.parcel_status_partial 'parcel_status_partial',  :controller => 'parcels', 
                                    :action => 'parcel_status_partial', 
                                    :method => :get
  
  map.purchase_request_supply_in_one_line 'purchase_request_supply_in_one_line',  :controller => 'purchase_requests', 
                                    :action => 'purchase_request_supply_in_one_line', 
                                    :method => :get
  
  map.auto_complete_for_supply_reference 'auto_complete_for_supply_reference',  :controller => 'purchase_orders', 
                                                                                :action     => 'auto_complete_for_supply_reference', 
                                                                                :method     => :get
  
  map.auto_complete_for_supplier_name 'auto_complete_for_supplier_name',  :controller => 'purchase_orders', 
                                                                          :action     => 'auto_complete_for_supplier_name', 
                                                                          :method     => :get
  
  map.pending_purchase_orders 'purchase_orders/pending', :controller => 'pending_purchase_orders', :action => 'index'
  map.closed_purchase_orders  'purchase_orders/closed',  :controller => 'closed_purchase_orders',  :action => 'index'
  
  map.resources :purchase_orders do |order|
    order.cancel                      'cancel',                                   :controller => 'purchase_orders', :action => 'cancel'
    order.cancel_supply               'cancel_supply/:purchase_order_supply_id',  :controller => 'purchase_orders', :action => 'cancel_supply'
    order.cancel_form                 'cancel_form',                              :controller => 'purchase_orders', :action => 'cancel_form'
    order.attached_invoice_document   'attached_invoice_document',                :controller => 'purchase_orders', :action => 'attached_invoice_document'
    order.attached_quotation_document 'attached_quotation_document',              :controller => 'purchase_orders', :action =>'attached_quotation_document'
    
    order.confirm       'confirm',        :controller => 'purchase_orders', :action => 'confirm', :conditions => { :method => :put }
    order.confirm_form  'confirm_form',   :controller => 'purchase_orders', :action => 'confirm_form'
    order.complete      'complete',       :controller => 'purchase_orders', :action => 'complete', :conditions => { :method => :put }
    order.complete_form 'complete_form',  :controller => 'purchase_orders', :action => 'complete_form'
    order.resources :parcels do |parcel|
      parcel.attached_delivery_document 'attached_delivery_document', :controller => 'parcels', :action => 'attached_delivery_document'
      parcel.alter_status               'alter_status',               :controller => 'parcels', :action => 'alter_status'
      parcel.process_by_supplier_form   'process_by_supplier_form',   :controller => 'parcels', :action => 'process_by_supplier_form'
      parcel.process_by_supplier        'process_by_supplier',        :controller => 'parcels', :action => 'process_by_supplier'
      parcel.ship_form                  'ship_form',                  :controller => 'parcels', :action => 'ship_form'
      parcel.receive_by_forwarder_form  'receive_by_forwarder_form',  :controller => 'parcels', :action => 'receive_by_forwarder_form'
      parcel.receive_form               'receive_form',               :controller => 'parcels', :action => 'receive_form'
      parcel.cancel_form                'cancel_form',                :controller => 'parcels', :action => 'cancel_form'
      parcel.process_by_supplier        'process_by_supplier',        :controller => 'parcels', :action => "process_by_supplier"
      parcel.ship                       'ship',                       :controller => 'parcels', :action => "ship"
      parcel.receive_by_forwarder       'receive_by_forwarder',       :controller => 'parcels', :action => "receive_by_forwarder"
      parcel.receive                    'receive',                    :controller => 'parcels', :action => "receive"
      parcel.cancel                     'cancel',                     :controller => 'parcels', :action => "cancel"
      
      parcel.resources :parcel_items do |parcel_item|
        parcel_item.cancel      'cancel',       :controller => 'parcel_items', :action => 'cancel'
        parcel_item.cancel_form 'cancel_form',  :controller => 'parcel_items', :action => 'cancel_form'
        parcel_item.report      'report',       :controller => 'parcel_items', :action => 'report'
        parcel_item.report_form 'report_form',  :controller => 'parcel_items', :action => 'report_form'
      end
    end
    order.resources :purchase_order_supplies do |purchase_order_supply|
      purchase_order_supply.cancel      'cancel',       :controller => 'purchase_order_supplies', :action => 'cancel'
      purchase_order_supply.cancel_form 'cancel_form',  :controller => 'purchase_order_supplies', :action => 'cancel_form'
    end
  end
  
  map.purchases 'purchases', :controller => 'pending_purchase_orders', :action => 'index'  # default page for purchases\
end
