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
  
  map.update_supplier_contacts      'update_supplier_contacts', :controller => 'quotation_requests', :action => 'update_supplier_contacts'
  map.resources :quotation_requests do |quotation_request|
    quotation_request.confirm                       'confirm',                        :controller => 'quotation_requests', :action => 'confirm', :conditions => { :method => :put }
    quotation_request.cancel                        'cancel',                         :controller => 'quotation_requests', :action => 'cancel'
    quotation_request.cancel_form                   'cancel_form',                    :controller => 'quotation_requests', :action => 'cancel_form'
    quotation_request.make_copy                     'make_copy',                      :controller => 'quotation_requests', :action => 'make_copy'
    quotation_request.review                        'review',                         :controller => 'quotation_requests', :action => 'review'
    quotation_request.send_to_another_supplier      'send_to_another_supplier',       :controller => 'quotation_requests', :action => 'send_to_another_supplier'
    quotation_request.send_to_another_supplier_form 'send_to_another_supplier_form',  :controller => 'quotation_requests', :action => 'send_to_another_supplier_form'
  end
  
  map.quotation_supply          'quotation_supply',           :controller => 'quotations',  :action => 'quotation_supply', :method => :get
  map.prepare_for_new_quotation 'quotations/prepare_for_new', :controller => 'quotations',  :action => 'prepare_for_new'
  
  map.resources :quotations do |quotation|
    quotation.sign                          'sign',                           :controller => 'quotations', :action => 'sign', :conditions => { :method => :put }
    quotation.sign_form                     'sign_form',                      :controller => 'quotations', :action => 'sign_form'
    quotation.send_to_supplier              'send_to_supplier',               :controller => 'quotations', :action => 'send_to_supplier', :conditions => { :method => :put }
    quotation.send_form                     'send_to_supplier_form',          :controller => 'quotations', :action => 'send_to_supplier_form'
    quotation.cancel                        'cancel',                         :controller => 'quotations', :action => 'cancel'
    quotation.cancel_form                   'cancel_form',                    :controller => 'quotations', :action => 'cancel_form'
  end
  
  map.parcel_status_partial 'parcel_status_partial',  :controller => 'parcels', 
                                    :action => 'parcel_status_partial', 
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
