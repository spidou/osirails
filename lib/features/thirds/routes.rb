ActionController::Routing::Routes.add_routes do |map|
  map.resources :customers do |customer|
    customer.resources :contacts
    customer.resources :establishments do |establishment|
      establishment.resources :contacts
    end
  end
  
  map.resources :suppliers do |supplier|
    supplier.resources :contacts
  end
  
  map.thirds 'thirds', :controller => 'customers' #default page for thirds
  
  map.auto_complete_for_customer_name 'auto_complete_for_customer_name', :controller => 'customers', 
                                                                         :action => 'auto_complete_for_customer_name',
                                                                         :method => :get
end
