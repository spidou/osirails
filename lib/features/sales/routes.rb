ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    # step commercial
    order.step_commercial 'commercial', :controller => 'step_commercial'
    order.resource :step_survey,             :as => 'survey',             :controller => 'step_survey' # :only => [ :show, :edit, :update ]
    order.resource :step_graphic_conception, :as => 'graphic_conception', :controller => 'step_graphic_conception'
    order.resource :step_estimate,           :as => 'estimate',           :controller => 'step_estimate' do |step_estimate|
      step_estimate.resources :quotes
    end
    
    # step invoicing
    order.step_invoicing 'invoicing', :controller => 'step_invoicing'
    
    # other resources
    order.resources :logs
    order.informations 'informations', :controller => 'informations'
  end
  
  map.closed       'closed',       :controller => 'closed_orders'
  map.archived     'archived',     :controller => 'archived_orders'
  
  map.prospectives 'prospectives', :controller => 'commercial_orders'
  map.invoicings   'invoicings',   :controller => 'invoicing_orders'
  map.in_progress  'in_progress',  :controller => 'in_progress_orders'
  map.sales        'sales',        :controller => 'commercial_orders'# :controller => 'invoicing_orders'
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller => 'customers', 
                                                                         :action => 'auto_complete_for_customer_name',
                                                                         :method => :get
  
  map.auto_complete_for_product_reference_reference 'auto_complete_for_product_reference_reference',
                                               :controller => 'product_references',
                                               :action => 'auto_complete_for_product_reference_reference',
                                               :method => :get
end
