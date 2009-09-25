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
          quote.validate   'validate',    :controller => 'quotes',
                                          :action     => 'validate',
                                          :conditions => { :method => :get }
          
          quote.invalidate 'invalidate',  :controller => 'quotes',
                                          :action     => 'invalidate',
                                          :conditions => { :method => :get }
          
          quote.send_form  'send_form',   :controller => 'quotes',
                                          :action     => 'send_form',
                                          :conditions => { :method => :get }
          
          quote.send_to_customer 'send',  :controller => 'quotes',
                                          :action     => 'send_to_customer',
                                          :conditions => { :method => :put }
          
          quote.sign_form  'sign_form',   :controller => 'quotes',
                                          :action     => 'sign_form',
                                          :conditions => { :method => :get }
          
          quote.sign       'sign',        :controller => 'quotes',
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
      invoicing.resource :invoice_step, :as => 'invoice', :controller => 'invoice_step'
      invoicing.resource :payment_step, :as => 'payment', :controller => 'payment_step'
    end
    
    # other resources
    order.resources :logs
    order.informations 'informations',        :controller => 'informations'
  end
  
  map.closed_orders         'closed_orders',         :controller => 'closed_orders'
  map.archived_orders       'archived_orders',       :controller => 'archived_orders'
  map.in_progress_orders    'in_progress_orders',    :controller => 'in_progress_orders'
  map.commercial_orders     'commercial_orders',     :controller => 'commercial_orders'
  map.pre_invoicing_orders  'pre_invoicing_orders',  :controller => 'pre_invoicing_orders'
  map.invoicing_orders      'invoicing_orders',      :controller => 'invoicing_orders'
  
  map.sales                 'sales',                 :controller => 'commercial_orders' # default route for sales
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller => 'customers', 
                                                                         :action => 'auto_complete_for_customer_name',
                                                                         :method => :get
  
  map.auto_complete_for_product_reference_reference 'auto_complete_for_product_reference_reference',
                                               :controller => 'product_references',
                                               :action => 'auto_complete_for_product_reference_reference',
                                               :method => :get
end
