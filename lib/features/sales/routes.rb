ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    order.current_step 'current', :controller => 'orders', :action => 'current_step'
    
    # commercial step
    order.commercial_step 'commercial', :controller => 'commercial_step'
    
    order.with_options :name_prefix => 'order_commercial_step_' do |commercial|
      commercial.resource :survey_step, :as => 'survey', :controller  => 'survey_step' # :only => [ :show, :edit, :update ]
      
      commercial.resource :quote_step, :as => 'quote', :controller  => 'quote_step' do |quote_step|
        quote_step.resources :quotes do |quote|
          quote.confirm           'confirm',    :controller => 'quotes',
                                                :action     => 'confirm',
                                                :conditions => { :method => :get }
          
          quote.cancel            'cancel',     :controller => 'quotes',
                                                :action     => 'cancel',
                                                :conditions => { :method => :get }
          
          quote.send_form         'send_form',  :controller => 'quotes',
                                                :action     => 'send_form',
                                                :conditions => { :method => :get }
          
          quote.send_to_customer  'send',       :controller => 'quotes',
                                                :action     => 'send_to_customer',
                                                :conditions => { :method => :put }
          
          quote.sign_form         'sign_form',  :controller => 'quotes',
                                                :action     => 'sign_form',
                                                :conditions => { :method => :get }
          
          quote.sign              'sign',       :controller => 'quotes',
                                                :action     => 'sign',
                                                :conditions => { :method => :put }
          
          quote.order_form        'order_form', :controller => 'quotes',
                                                :action     => 'order_form',
                                                :conditions => { :method => :get }
        end
        
        quote_step.new_quote_item 'new_quote_item', :controller  => 'quotes',
                                                    :action      => 'new_quote_item',
                                                    :conditions  => { :method => :post }
      end
      
      commercial.resource :press_proof_step, :as => 'press_proof', :controller  => 'press_proof_step' do |press_proof_step|
      
        press_proof_step.resources :press_proofs do |press_proof|
          press_proof.confirm             'confirm',            :controller => 'press_proofs',
                                                                :action     => 'confirm',
                                                                :conditions => { :method => :get }
          
          press_proof.cancel              'cancel',             :controller => 'press_proofs',
                                                                :action     => 'cancel',
                                                                :conditions => { :method => :get }
          
          press_proof.send_form           'send_form',          :controller => 'press_proofs',
                                                                :action     => 'send_form',
                                                                :conditions => { :method => :get }
          
          press_proof.send_to_customer    'send',               :controller => 'press_proofs',
                                                                :action     => 'send_to_customer',
                                                                :conditions => { :method => :put }
          
          press_proof.sign_form           'sign_form',          :controller => 'press_proofs',
                                                                :action     => 'sign_form',        
                                                                :conditions => { :method => :get }
          
          press_proof.sign                'sign',               :controller => 'press_proofs',
                                                                :action     => 'sign',             
                                                                :conditions => { :method => :put }
          
          press_proof.signed_press_proof  'signed_press_proof', :controller => 'press_proofs',
                                                                :action     => 'signed_press_proof',
                                                                :conditions => { :method => :get }
          
          press_proof.revoke_form         'revoke_form',        :controller => 'press_proofs',
                                                                :action     => 'revoke_form',      
                                                                :conditions => { :method => :get }
          
          press_proof.revoke              'revoke',             :controller => 'press_proofs',
                                                                :action     => 'revoke',           
                                                                :conditions => { :method => :put }
        end
        press_proof_step.add_mockup       'add_mockup',         :controller => 'press_proofs',
                                                                :action     => 'add_mockup',       
                                                                :conditions => { :method => :get }
      end
      
    end
    
    # production step
    order.production_step 'production', :controller => 'production_step'
    
    order.with_options :name_prefix => 'order_production_step_' do |production|
      production.resource :manufacturing_step, :as => 'manufacturing', :controller => 'manufacturing_step'
    end
    
    # delivering step
    order.delivering_step 'delivering', :controller => 'delivering_step'
    
    order.with_options :name_prefix => 'order_delivering_step_' do |delivering|
      delivering.resource :delivery_step, :as => 'delivery', :controller => 'delivery_step' do |delivery_step|
        delivery_step.resources :delivery_notes do |delivery_note|
          delivery_note.confirm       'confirm',        :controller => 'delivery_notes',
                                                        :action     => 'confirm',
                                                        :conditions => { :method => :get }
          
          delivery_note.cancel        'cancel',         :controller => 'delivery_notes',
                                                        :action     => 'cancel',
                                                        :conditions => { :method => :get }
          
          delivery_note.sign_form     'sign_form',      :controller => 'delivery_notes',
                                                        :action     => 'sign_form',
                                                        :conditions => { :method => :get }
          
          delivery_note.sign          'sign',           :controller => 'delivery_notes',
                                                        :action     => 'sign',
                                                        :conditions => { :method => :put }
          
          delivery_note.schedule_form 'schedule_form',  :controller => 'delivery_notes',
                                                        :action     => 'schedule_form',
                                                        :conditions => { :method => :get }
          
          delivery_note.schedule      'schedule',       :controller => 'delivery_notes',
                                                        :action     => 'schedule',
                                                        :conditions => { :method => :put }
          
          delivery_note.realize_form  'realize_form',   :controller => 'delivery_notes',
                                                        :action     => 'realize_form',
                                                        :conditions => { :method => :get }
          
          delivery_note.realize       'realize',        :controller => 'delivery_notes',
                                                        :action     => 'realize',
                                                        :conditions => { :method => :put }
          
          delivery_note.attachment    'attachment',     :controller => 'delivery_notes',
                                                        :action     => 'attachment',
                                                        :conditions => { :method => :get }
          
          delivery_note.resources :delivery_interventions do |delivery_intervention|
            delivery_intervention.report 'report',  :controller => 'delivery_interventions',
                                                    :action     => 'report',
                                                    :conditions => { :method => :get }
          end
        end
      end
    end
    
    # invoicing step
    order.invoicing_step 'invoicing', :controller => 'invoicing_step'
    
    order.with_options :name_prefix => 'order_invoicing_step_' do |invoicing|
      invoicing.resource :invoice_step, :as => 'invoice', :controller => 'invoice_step' do |invoice_step|
        invoice_step.resources :invoices do |invoice|
          invoice.confirm 'confirm',                                        :controller => 'invoices',
                                                                            :action     => 'confirm',
                                                                            :conditions => { :method => :get }
          
          invoice.cancel_form 'cancel_form',                                :controller => 'invoices',
                                                                            :action     => 'cancel_form',
                                                                            :conditions => { :method => :get }
          
          invoice.cancel 'cancel',                                          :controller => 'invoices',
                                                                            :action     => 'cancel',
                                                                            :conditions => { :method => :put }
          
          invoice.send_form 'send_form',                                    :controller => 'invoices',
                                                                            :action     => 'send_form',
                                                                            :conditions => { :method => :get }
          
          invoice.send_to_customer 'send',                                  :controller => 'invoices',
                                                                            :action     => 'send_to_customer',
                                                                            :conditions => { :method => :put }
          
          invoice.abandon_form 'abandon_form',                              :controller => 'invoices',
                                                                            :action     => 'abandon_form',
                                                                            :conditions => { :method => :get }
          
          invoice.abandon 'abandon',                                        :controller => 'invoices',
                                                                            :action     => 'abandon',
                                                                            :conditions => { :method => :put }
          
          invoice.ajax_request_for_invoice_items 'ajax_request_for_invoice_items/:delivery_note_ids',
                                                 :controller         => 'invoices',
                                                 :action             => 'ajax_request_for_invoice_items',
                                                 :method             => :get,
                                                 :delivery_note_ids  => 0
        end
        
        invoice_step.ajax_request_for_invoice_items 'ajax_request_for_invoice_items/:delivery_note_ids',
                                                    :controller         => 'invoices',
                                                    :action             => 'ajax_request_for_invoice_items',
                                                    :method             => :get,
                                                    :delivery_note_ids  => 0
      end
      
      invoicing.resource :payment_step, :as => 'payment', :controller => 'payment_step' do |payment_step|
        payment_step.resources :invoices do |invoice|
          invoice.factoring_pay_form 'factoring_pay_form',                  :controller => 'invoices',
                                                                            :action     => 'factoring_pay_form',
                                                                            :conditions => { :method => :get }
          
          invoice.factoring_pay 'factoring_pay',                            :controller => 'invoices',
                                                                            :action     => 'factoring_pay',
                                                                            :conditions => { :method => :put }
          
          invoice.factoring_recover_form 'factoring_recover_form',          :controller => 'invoices',
                                                                            :action     => 'factoring_recover_form',
                                                                            :conditions => { :method => :get }
          
          invoice.factoring_recover 'factoring_recover',                    :controller => 'invoices',
                                                                            :action     => 'factoring_recover',
                                                                            :conditions => { :method => :put }
          
          invoice.factoring_balance_pay_form 'factoring_balance_pay_form',  :controller => 'invoices',
                                                                            :action     => 'factoring_balance_pay_form',
                                                                            :conditions => { :method => :get }
          
          invoice.factoring_balance_pay 'factoring_balance_pay',            :controller => 'invoices',
                                                                            :action     => 'factoring_balance_pay',
                                                                            :conditions => { :method => :put }
          
          invoice.due_date_pay_form 'due_date_pay_form',                    :controller => 'invoices',
                                                                            :action     => 'due_date_pay_form',
                                                                            :conditions => { :method => :get }
          
          invoice.due_date_pay 'due_date_pay',                              :controller => 'invoices',
                                                                            :action     => 'due_date_pay',
                                                                            :conditions => { :method => :put }
          
          invoice.totally_pay_form 'totally_pay_form',                      :controller => 'invoices',
                                                                            :action     => 'totally_pay_form',
                                                                            :conditions => { :method => :get }
          
          invoice.totally_pay 'totally_pay',                                :controller => 'invoices',
                                                                            :action     => 'totally_pay',
                                                                            :conditions => { :method => :put }
        end
      end
    end
    
    # other resources
    order.resources :graphic_items    
    order.resources :mockups    
    order.resources :graphic_documents
    
    order.resources :mockups do |mockup|      
      mockup.cancel 'cancel',     :controller => 'mockups',
                                  :action     => 'cancel',
                                  :conditions => { :method => :get }
      
      mockup.refresh_links     'refresh_links',     :controller => 'mockups', :action => 'refresh_links'
      mockup.add_to_spool      'add_to_spool',      :controller => 'mockups', :action => 'add_to_spool'
      mockup.remove_from_spool 'remove_from_spool', :controller => 'mockups', :action => 'remove_from_spool'
    end
    
    order.resources :graphic_documents do |graphic_document|      
      graphic_document.cancel 'graphic_document',     :controller => 'graphic_documents',
                                                      :action     => 'cancel',
                                                      :conditions => { :method => :get }
      
      graphic_document.refresh_links     'refresh_links',     :controller => 'graphic_documents', :action => 'refresh_links' 
      graphic_document.add_to_spool      'add_to_spool',      :controller => 'graphic_documents', :action => 'add_to_spool'
      graphic_document.remove_from_spool 'remove_from_spool', :controller => 'graphic_documents', :action => 'remove_from_spool'
    end
    
    order.resources :dunnings, :path_prefix => "orders/:order_id/:owner/:owner_id" do |dunning|
      dunning.cancel 'cancel', :controller => 'dunnings', :action => 'cancel', :conditions => { :method => :get } 
    end
    
    order.resources :graphic_item_spool_items do |spool_item|
      spool_item.remove_from_spool 'remove_from_spool', :controller => 'graphic_item_spool_items', :action => 'remove_from_spool'
    end
    
    order.empty_graphic_item_spool_items 'empty_graphic_item_spool_items', :controller => 'graphic_item_spool_items', :action => 'empty_spool'
    
    order.resources :logs
    order.informations 'informations', :controller => 'informations'
  end 
  
  # attachments
  map.payment_attachment    'payment_attachments/:id',    :controller => 'payment_attachments',     :action => 'show'
  map.adjustment_attachment 'adjustment_attachments/:id', :controller => 'adjustment_attachments',  :action => 'show'
  
  map.graphic_item_versions 'graphic_item_versions', :controller => 'graphic_item_versions'
  map.graphic_item_version  'graphic_item_versions/:id/:type/:style', :controller => 'graphic_item_versions',
                                                                      :action     => 'show',
                                                                      :style      => 'original'
  
  map.closed_orders         'closed_orders',        :controller => 'closed_orders'
  map.archived_orders       'archived_orders',      :controller => 'archived_orders'
  map.in_progress_orders    'in_progress_orders',   :controller => 'in_progress_orders'
  map.commercial_orders     'commercial_orders',    :controller => 'commercial_orders'
  map.production_orders     'production_orders',    :controller => 'production_orders'
  map.delivering_orders     'delivering_orders',    :controller => 'delivering_orders'
  map.pre_invoicing_orders  'pre_invoicing_orders', :controller => 'pre_invoicing_orders'
  map.invoicing_orders      'invoicing_orders',     :controller => 'invoicing_orders'
  
  map.quote_management    'quote_management',   :controller => 'quote_management'
  map.invoice_management  'invoice_management', :controller => 'invoice_management'
  map.payment_management  'payment_management', :controller => 'payment_management'
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller  => 'customers', 
                                                                         :action      => 'auto_complete_for_customer_name',
                                                                         :method      => :get
  
  map.auto_complete_for_product_reference_reference 'auto_complete_for_product_reference_reference',
                                                    :controller  => 'product_references',
                                                    :action      => 'auto_complete_for_product_reference_reference',
                                                    :method      => :get
  
  map.resources :product_reference_categories do |product_reference_category|
    product_reference_category.disable 'disable', :controller => 'product_reference_categories',
                                                  :action     => 'disable',
                                                  :conditions => { :method => :get }
    product_reference_category.enable  'enable',  :controller => 'product_reference_categories',
                                                  :action     => 'enable',
                                                  :conditions => { :method => :get }
    
    product_reference_category.resources :product_reference_sub_categories
  end
  
  map.resources :product_reference_sub_categories do |product_reference_sub_category|
    product_reference_sub_category.disable 'disable', :controller => 'product_reference_sub_categories',
                                                      :action     => 'disable',
                                                      :conditions => { :method => :get }
    product_reference_sub_category.enable  'enable',  :controller => 'product_reference_sub_categories',
                                                      :action     => 'enable',
                                                      :conditions => { :method => :get }
    
    product_reference_sub_category.resources :product_references
  end
  
  map.resources :product_references do |product_reference|
    product_reference.resources :end_products
  end
  
  map.resources :end_products
  
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
  map.products_catalog 'products_catalog', :controller => 'products_catalog'
  map.goods 'goods', :controller => 'product_reference_manager' #default page for products
  
  # AJAX REQUESTS
  map.update_product_reference_sub_categories 'update_product_reference_sub_categories', :controller  => 'product_reference_categories',
                                                                                         :action      => 'update_product_reference_sub_categories'
  ##
  
  map.resources :service_deliveries
  
  map.resources :subcontractors
  
  map.connect 'subcontractor_requests/:id/quote', :controller => 'subcontractor_requests',
                                                  :action     => 'quote',
                                                  :conditions => { :method => :get }
  
  ## SALES ADMIN
  map.sales_admin 'sales_admin', :controller => 'sales_admin'
  map.resources :order_types
  ##
  
  map.sales_monitoring 'sales_monitoring', :controller => 'sales'
  map.sales_management 'sales_management', :controller => 'sales'
  
  map.sales 'sales', :controller => 'sales' # default route for sales
end
