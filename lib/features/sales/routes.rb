ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    # commercial step
    order.commercial_step 'commercial',       :controller => 'commercial_step'
    order.resource :survey_step,              :as => 'survey',             :controller => 'survey_step' # :only => [ :show, :edit, :update ]
    order.resource :graphic_conception_step,  :as => 'graphic_conception', :controller => 'graphic_conception_step'
    order.resource :estimate_step,            :as => 'estimate',           :controller => 'estimate_step' do |estimate_step|
      estimate_step.resources :quotes
    end
    
    # pre invoicing step
    order.pre_invoicing_step 'pre_invoicing', :controller => 'pre_invoicing_step'
    order.resource :delivery_step,            :as => 'delivery',           :controller => 'delivery_step'
    
    # invoicing step
    order.invoicing_step 'invoicing',         :controller => 'invoicing_step'
    order.resource :invoice_step,             :as => 'invoice',            :controller => 'invoice_step'
    order.resource :payment_step,             :as => 'payment',            :controller => 'payment_step'
    
    # other resources
    order.resources :logs
    order.informations 'informations',        :controller => 'informations'
  end
  
  map.closed          'closed',               :controller => 'closed_orders'
  map.archived        'archived',             :controller => 'archived_orders'
  
  map.prospectives    'prospectives',         :controller => 'commercial_orders'
  map.pre_invoicings  'pre_invoicings',       :controller => 'pre_invoicing_orders'
  map.invoicings      'invoicings',           :controller => 'invoicing_orders'
  map.in_progress     'in_progress',          :controller => 'in_progress_orders'
  map.sales           'sales',                :controller => 'commercial_orders'# :controller => 'invoicing_orders'
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller => 'customers', 
                                                                         :action => 'auto_complete_for_customer_name',
                                                                         :method => :get
  
  map.auto_complete_for_product_reference_reference 'auto_complete_for_product_reference_reference',
                                               :controller => 'product_references',
                                               :action => 'auto_complete_for_product_reference_reference',
                                               :method => :get
end
