ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  map.login 'login', :controller => 'account'
  map.logout 'logout', :controller => 'account',  :action => 'logout'

  # begin | To create the url architecture "/permissions/*"
  map.resources :business_object_permissions, :path_prefix => 'permissions'
  map.resources :menu_permissions, :path_prefix => 'permissions'
  map.resources :role_permissions, :path_prefix => 'permissions'
  map.permissions "permissions", :controller => "permissions"
  # end
  
  # begin | To create the url architecture "/society_configurations/*"
  map.resources :society_identity_configuration, :path_prefix => 'society_configurations'
  map.resources :activity_sectors, :path_prefix => 'society_configurations'
  map.resources :services, :path_prefix => 'society_configurations'
  map.society_configurations "society_configurations", :controller => "society_configurations"
  # end
  
  map.resources :users
  map.resources :roles
  map.resources :features
  map.resources :menus
  map.resources :contents
  map.resources :password_policies
  map.resources :employees do |employee|
    employee.resources :salaries
  end
  map.resources :customers
  map.resources :suppliers
#  map.resources :establishments
  map.resources :product_references
  map.resources :product_reference_categories
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
  map.resources :cities, :collection => {:auto_complete_for_city_name => :get }
  map.resources :job_contracts
  map.resources :jobs
  
  map.resources :cities, :collection => {:auto_complete_for_city_name => :get }
  
  map.resources :customers do |customer|
    customer.resources :contacts
    customer.resources :establishments do |establishment|
      establishment.resources :contacts
    end
  end   
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
