# Permit to add new route from another files
module ActionController
  module Routing
    class RouteSet
      def add_routes
        yield Mapper.new(self)
        install_helpers([ActionController::Base, ActionView::Base], true)
      end    
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  ### ROOT
  map.root :controller => "account"
  map.search "search" , :controller => "searches"
  ### END ROOT

  map.login 'login', :controller => 'account'
  map.logout 'logout', :controller => 'account',  :action => 'logout'
  
  ### COMMONS
  map.resources :cities, :collection => {:auto_complete_for_city_name => :get }
  map.resources :contacts, :collection => {:auto_complete_for_contact_name => :get}
  map.resources :activity_sectors, :collection => {:auto_complete_for_activity_sector_name => :get }
  ### END COMMONS
  
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
features_path = ["#{RAILS_ROOT}/lib/features", "#{RAILS_ROOT}/vendor/features", "#{RAILS_ROOT}/lib/plugins"]
features_path.each do |p|
  list = Dir.open(p).sort
  list.each do |f|
    next unless f.grep(/\./).empty?
#    begin
#    feature = Feature.find_by_name(f)
#    (next unless feature.activated) if feature
#    rescue Exception => e
#      puts "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
#    end
    route_path = File.join(p, f, 'routes.rb')
    load route_path if File.exist?(route_path)
  end
end

ActionController::Routing::Routes.add_routes do |map|
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
