ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    # commercial step
    order.commercial_step 'commercial', :controller => 'commercial_step'
    
    order.with_options :name_prefix => 'order_commercial_step_' do |commercial|
      commercial.resource :survey_step,             :as          => 'survey',
                                                    :controller  => 'survey_step' # :only => [ :show, :edit, :update ]
      
      commercial.resource :graphic_conception_step, :as          => 'graphic_conception',
                                                    :controller  => 'graphic_conception_step'
      
      commercial.resource :estimate_step,           :as          => 'estimate',
                                                    :controller  => 'estimate_step' do |estimate_step|
        estimate_step.resources :quotes do |quote|
          quote.confirm 'confirm',        :controller => 'quotes',
                                          :action     => 'confirm',
                                          :conditions => { :method => :get }
          
          quote.cancel 'cancel',          :controller => 'quotes',
                                          :action     => 'cancel',
                                          :conditions => { :method => :get }
          
          quote.send_form 'send_form',    :controller => 'quotes',
                                          :action     => 'send_form',
                                          :conditions => { :method => :get }
          
          quote.send_to_customer 'send',  :controller => 'quotes',
                                          :action     => 'send_to_customer',
                                          :conditions => { :method => :put }
          
          quote.sign_form 'sign_form',    :controller => 'quotes',
                                          :action     => 'sign_form',
                                          :conditions => { :method => :get }
          
          quote.sign 'sign',              :controller => 'quotes',
                                          :action     => 'sign',
                                          :conditions => { :method => :put }
          
          quote.order_form 'order_form',  :controller => 'quotes',
                                          :action     => 'order_form',
                                          :conditions => { :method => :get }
        end
      end
    end
    
    # pre invoicing step
    order.pre_invoicing_step 'pre_invoicing', :controller => 'pre_invoicing_step'
    
    order.with_options :name_prefix => 'order_pre_invoicing_step_' do |pre_invoicing|
      pre_invoicing.resource :delivery_step, :as => 'delivery', :controller => 'delivery_step' do |delivery_step|
        delivery_step.resources :delivery_notes
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
      invoicing.resource :payment_step, :as => 'payment', :controller => 'payment_step'
    end
    
    # other resources
    order.resources :logs
    order.informations 'informations',        :controller => 'informations'
  end
  
  # attachments
  map.payment_attachment    'payment_attachments/:id',    :controller => 'payment_attachments',     :action => 'show'
  map.adjustment_attachment 'adjustment_attachments/:id', :controller => 'adjustment_attachments',  :action => 'show'
  
  
  map.closed_orders         'closed_orders',         :controller => 'closed_orders'
  map.archived_orders       'archived_orders',       :controller => 'archived_orders'
  map.in_progress_orders    'in_progress_orders',    :controller => 'in_progress_orders'
  map.commercial_orders     'commercial_orders',     :controller => 'commercial_orders'
  map.pre_invoicing_orders  'pre_invoicing_orders',  :controller => 'pre_invoicing_orders'
  map.invoicing_orders      'invoicing_orders',      :controller => 'invoicing_orders'
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller  => 'customers', 
                                                                         :action      => 'auto_complete_for_customer_name',
                                                                         :method      => :get
  
  map.auto_complete_for_product_reference_reference 'auto_complete_for_product_reference_reference',
                                               :controller  => 'product_references',
                                               :action      => 'auto_complete_for_product_reference_reference',
                                               :method      => :get
  
  map.resources :products
  map.resources :produts_catalog
  
  map.resources :product_references do |product_reference|
    product_reference.resources :products
  end
  
  map.resources :product_reference_categories do |product_reference_category|
    product_reference_category.resources :product_reference_categories
    product_reference_category.resources :product_references do |product_reference|
      product_reference.resources :products
    end
  end
  
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
  map.goods 'goods', :controller => 'products_catalog' #default page for products
  
  map.resources :subcontractors
  
  map.connect 'subcontractor_requests/:id/quote', :controller => 'subcontractor_requests',
                                                  :action     => 'quote',
                                                  :conditions => { :method => :get }
  
  map.sales 'sales', :controller => 'commercial_orders' # default route for sales
end
