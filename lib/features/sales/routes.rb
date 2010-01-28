ActionController::Routing::Routes.add_routes do |map|
  map.resources :orders do |order|
    # commercial step
    order.commercial_step 'commercial', :controller => 'commercial_step'
    
    order.with_options :name_prefix => 'order_commercial_step_' do |commercial|
      commercial.resource :survey_step,             :as          => 'survey',
                                                    :controller  => 'survey_step' # :only => [ :show, :edit, :update ]
      
      commercial.resource :estimate_step,           :as          => 'estimate',
                                                    :controller  => 'estimate_step' do |estimate_step|
        estimate_step.resources :quotes do |quote|
          quote.confirm   'confirm',      :controller => 'quotes',
                                          :action     => 'confirm',
                                          :conditions => { :method => :get }
          
          quote.cancel 'cancel',          :controller => 'quotes',
                                          :action     => 'cancel',
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
      
      commercial.resource :press_proof_step, :as => 'press_proof', :controller  => 'press_proof_step' do |press_proof_step|
      
        press_proof_step.resources :press_proofs do |press_proof|
          press_proof.confirm          'confirm',     :controller => 'press_proofs', :action     => 'confirm',          :conditions => { :method => :get }
          press_proof.cancel           'cancel',      :controller => 'press_proofs', :action     => 'cancel',           :conditions => { :method => :get }
          
          press_proof.send_form        'send_form',   :controller => 'press_proofs', :action     => 'send_form',        :conditions => { :method => :get }
          press_proof.send_to_customer 'send',        :controller => 'press_proofs', :action     => 'send_to_customer', :conditions => { :method => :put }
          
          press_proof.sign_form        'sign_form',   :controller => 'press_proofs', :action     => 'sign_form',        :conditions => { :method => :get }
          press_proof.sign             'sign',        :controller => 'press_proofs', :action     => 'sign',             :conditions => { :method => :put }
          
          press_proof.revoke_form      'revoke_form', :controller => 'press_proofs', :action     => 'revoke_form',      :conditions => { :method => :get }
          press_proof.revoke           'revoke',      :controller => 'press_proofs', :action     => 'revoke',           :conditions => { :method => :put }
          
          press_proof.resources :dunnings do |dunning|
            dunning.cancel             'cancel',      :controller => 'dunnings',     :action     => 'cancel',           :conditions => { :method => :get } 
          end
          
        end
        press_proof_step.add_mockup    'add_mockup',  :controller => 'press_proofs', :action     => 'add_mockup',       :conditions => { :method => :get }
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
    order.resources :graphic_items    
    order.resources :mockups    
    order.resources :graphic_documents
    
    order.resources :mockups do |mockup|      
      mockup.cancel 'cancel',     :controller => 'mockups',
                                  :action     => 'cancel',
                                  :conditions => { :method => :get }
      
      mockup.refresh_links 'refresh_links', :controller => 'mockups', :action => 'refresh_links'
    end
    
    order.resources :graphic_documents do |graphic_document|      
      graphic_document.cancel 'graphic_document',     :controller => 'graphic_documents',
                                                      :action     => 'cancel',
                                                      :conditions => { :method => :get }
      
      graphic_document.refresh_links 'refresh_links', :controller => 'graphic_documents', :action => 'refresh_links'
    end
    
    order.resources :logs
    order.informations 'informations',        :controller => 'informations'
  end 
  
  map.graphic_item_versions 'graphic_item_versions', :controller => 'graphic_item_versions'
  map.graphic_item_version  'graphic_item_versions/:id/:name.:format', :controller => 'graphic_item_versions',
                                                                       :action     => 'show'
                                                                          
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
end
