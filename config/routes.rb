ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  ### ROOT
  map.root :controller => "account", :action => "index"
  map.search "search" , :controller => "searches"
  ### END ROOT

  map.login 'account/login', :controller => 'account', :action => 'login'
  map.logout 'account/logout', :controller => 'account', :action => 'logout'
  
  ### COMMONS
  map.resources :cities, :collection => {:auto_complete_for_city_name => :get }
  map.resources :contacts, :collection => {:auto_complete_for_contact_name => :get}
  map.resources :activity_sectors, :collection => {:auto_complete_for_activity_sector_name => :get }
  ### END COMMONS
  
  map.connect 'attachments/:id/:style', :controller => 'attachments', :action => 'show'
  
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
end

# Add dynamicaly features routes
# the begin rescue enclosure permits to avoid errors while the installation because of the non-existent tables in the database (at this time)
begin
  $activated_features_path.each do |feature_path|
    if feature = Feature.find_by_name(feature_path.split('/').last)
      next unless feature.activated?
    end
    routes_path = File.join(feature_path, 'routes.rb')
    load routes_path if File.exist?(routes_path)
  end
rescue ActiveRecord::StatementInvalid, Mysql::Error => e
  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  RAKE_TASK ? puts(error) : raise(error)
end


ActionController::Routing::Routes.add_routes do |map|
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
