ActionController::Routing::Routes.add_routes do |map|

  map.resources :purchase_requests do |request|
    request.cancel_supply 'cancel_supply/:purchase_request_supply_id', :controller => 'purchase_requests', :action => 'cancel_supply'
    request.cancel        'cancel',       :controller => 'purchase_requests', :action => 'cancel'
    request.cancel_form   'cancel_form',  :controller => 'purchase_requests', :action => 'cancel_form'
  end
  
  map.resources "purchase_request_supplies"
  
  map.purchase_request_managements "purchase_request_managements", :controller => "purchase_request_supplies", :action => "index"
  
  map.prepare_for_new_quotation_request 'quotation_requests/prepare_for_new', :controller => 'quotation_requests', :action => 'prepare_for_new'
  
  map.quotation_request_supply 'quotation_request_supply', :controller => 'quotation_requests',
                                                           :action => 'quotation_request_supply',
                                                           :method => :get
  map.resources :quotation_requests
  
  
  map.purchase_delivery_status_partial 'purchase_delivery_status_partial',  :controller => 'purchase_deliveries', 
                                    :action => 'purchase_delivery_status_partial', 
                                    :method => :get
  
  map.purchase_request_supply_in_one_line 'purchase_request_supply_in_one_line',  :controller => 'purchase_requests', 
                                    :action => 'purchase_request_supply_in_one_line', 
                                    :method => :get
                                    
  map.auto_complete_for_supply 'auto_complete_for_supply',  :controller => 'quotation_requests', 
                                                            :action     => 'auto_complete_for_supply', 
                                                            :method     => :post
  
  map.auto_complete_for_supply_reference 'auto_complete_for_supply_reference',  :controller => 'purchase_orders', 
                                                                                :action     => 'auto_complete_for_supply_reference', 
                                                                                :method     => :get
  
  map.auto_complete_for_supplier_name 'auto_complete_for_supplier_name',  :controller => 'purchase_orders', 
                                                                          :action     => 'auto_complete_for_supplier_name', 
                                                                          :method     => :get
  
  map.purchase_order_supply_in_one_line 'purchase_order_supply_in_one_line',  :controller => 'purchase_orders', 
                                    :action => 'purchase_order_supply_in_one_line', 
                                    :method => :get
  
  map.pending_purchase_orders 'purchase_orders/pending', :controller => 'pending_purchase_orders', :action => 'index'
  
  map.closed_purchase_orders  'purchase_orders/closed',  :controller => 'closed_purchase_orders',  :action => 'index'
  
  map.prepare_for_new_purchase_order 'purchase_orders/prepare_for_new', :controller => 'purchase_orders', :action => 'prepare_for_new'
  
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
    order.resources :purchase_deliveries do |purchase_delivery|
      purchase_delivery.attached_delivery_document 'attached_delivery_document', :controller => 'purchase_deliveries', :action => 'attached_delivery_document'
      purchase_delivery.alter_status               'alter_status',               :controller => 'purchase_deliveries', :action => 'alter_status'
      purchase_delivery.process_by_supplier_form   'process_by_supplier_form',   :controller => 'purchase_deliveries', :action => 'process_by_supplier_form'
      purchase_delivery.process_by_supplier        'process_by_supplier',        :controller => 'purchase_deliveries', :action => 'process_by_supplier'
      purchase_delivery.ship_form                  'ship_form',                  :controller => 'purchase_deliveries', :action => 'ship_form'
      purchase_delivery.receive_by_forwarder_form  'receive_by_forwarder_form',  :controller => 'purchase_deliveries', :action => 'receive_by_forwarder_form'
      purchase_delivery.receive_form               'receive_form',               :controller => 'purchase_deliveries', :action => 'receive_form'
      purchase_delivery.cancel_form                'cancel_form',                :controller => 'purchase_deliveries', :action => 'cancel_form'
      purchase_delivery.process_by_supplier        'process_by_supplier',        :controller => 'purchase_deliveries', :action => "process_by_supplier"
      purchase_delivery.ship                       'ship',                       :controller => 'purchase_deliveries', :action => "ship"
      purchase_delivery.receive_by_forwarder       'receive_by_forwarder',       :controller => 'purchase_deliveries', :action => "receive_by_forwarder"
      purchase_delivery.receive                    'receive',                    :controller => 'purchase_deliveries', :action => "receive"
      purchase_delivery.cancel                     'cancel',                     :controller => 'purchase_deliveries', :action => "cancel"
      
      purchase_delivery.resources :purchase_delivery_items do |purchase_delivery_item|
        purchase_delivery_item.cancel      'cancel',       :controller => 'purchase_delivery_items', :action => 'cancel'
        purchase_delivery_item.cancel_form 'cancel_form',  :controller => 'purchase_delivery_items', :action => 'cancel_form'
        purchase_delivery_item.report      'report',       :controller => 'purchase_delivery_items', :action => 'report'
        purchase_delivery_item.report_form 'report_form',  :controller => 'purchase_delivery_items', :action => 'report_form'
      end
    end
    order.resources :purchase_order_supplies do |purchase_order_supply|
      purchase_order_supply.cancel      'cancel',       :controller => 'purchase_order_supplies', :action => 'cancel'
      purchase_order_supply.cancel_form 'cancel_form',  :controller => 'purchase_order_supplies', :action => 'cancel_form'
    end
  end
  
  map.purchases 'purchases', :controller => 'pending_purchase_orders', :action => 'index'  # default page for purchases\
end
