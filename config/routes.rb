ActionController::Routing::Routes.draw do |map|
  
  ## Add document routes
  ActAsFileRoute.add_routes_to map #FIXME modifier le nom de la class
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  ### ROOT
  map.root :controller => "account"
  ### END ROOT
  
  ### ADMIN
  map.login 'login', :controller => 'account'
  map.logout 'logout', :controller => 'account',  :action => 'logout'

  # begin | To create the url architecture "/permissions/*"
  map.resources :business_object_permissions, :path_prefix => 'permissions'
  map.resources :menu_permissions, :path_prefix => 'permissions'
  map.resources :role_permissions, :path_prefix => 'permissions'
  map.resources :document_permissions, :path_prefix => 'permissions'
  map.resources :calendar_permissions, :path_prefix => 'permissions'
  map.permissions "permissions", :controller => "role_permissions"
  # end
  
  # begin | To create the url architecture "/society_configurations/*"
  map.resources :society_activity_sectors, :path_prefix => 'society_configurations'
  map.resources :services, :path_prefix => 'society_configurations'
  map.society_identity_configuration "society_identity_configuration", :path_prefix => 'society_configurations', :controller => "society_identity_configuration"
  map.society_configurations "society_configurations", :controller => "society_identity_configuration"
  # end
  
  map.resources :users
  map.resources :roles
  map.resources :features
  map.resources :menus
  map.resources :contents
  map.resources :password_policies
  
  map.connect 'admin', :controller => 'users' #default page for admin
  ### END ADMIN
  
  ### HUMAN RESOURCES
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
  end
  map.resources :jobs
  
  map.connect 'rh', :controller => 'employees' #default page for human resources
  ### END HUMAN RESOURCES
  
  ### SALES
  map.resources :customers do |customer|
    customer.resources :contacts
    customer.resources :establishments do |establishment|
      establishment.resources :contacts
    end
  end
  map.resources :suppliers do |supplier|
    supplier.resources :contacts
  end
  map.connect 'thirds', :controller => 'customers' #default page for thirds
  ### END SALES
  
  ### PRODUCTS
  map.resources :products
  map.resources :produts_catalog
  map.resources :product_references
  map.resources :product_reference_categories do |product_reference_category|
    product_reference_category.resources :product_reference_categories
    product_reference_category.resources :product_references do |product_reference|
      product_reference.resources :products
    end
  end
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
#  map.connect 'products', :controller => 'products_catalog' #default page for products
  ### END PRODUCTS
  
  ### CALENDAR
  map.resources :calendars do |calendar|
    calendar.resources :events
  end
  map.connect 'calendars/auto_complete_for_event_participants/:id', :controller => 'calendars', :action => 'auto_complete_for_event_participants'
  map.connect 'calendars/:id/:period/:year/:month/:day', :controller => 'calendars', :action => 'show', :period => nil, :year => nil, :month => nil, :day => nil
  ### END CALENDAR

  ### COMMONS
  map.resources :cities, :collection => {:auto_complete_for_city_name => :get }
  map.resources :contacts, :collection => {:auto_complete_for_contact_name => :get}
  map.resources :activity_sectors, :collection => {:auto_complete_for_activity_sector_name => :get }
  ### END COMMONS
  
  ### LOGISTICS
  map.resources :commodities
  map.resources :commodity_categories
  map.commodities_manager "commodities_manager", :controller => "commodities_manager"
  map.connect 'logistics', :controller => 'commodities_manager' #default page for products
  map.resources :inventories
  map.resources :commodities_inventories
  ### END LOGISTICS
  
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

#ActionController::Routing::Routes.routes.each{|r| puts r} 
