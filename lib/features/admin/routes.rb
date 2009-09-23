ActionController::Routing::Routes.add_routes do |map|
  # permissions
  map.resources :business_object_permissions, :path_prefix => 'permissions'
  map.resources :menu_permissions, :path_prefix => 'permissions'
  map.resources :role_permissions, :path_prefix => 'permissions'
  map.resources :document_type_permissions, :path_prefix => 'permissions'
  map.resources :calendar_permissions, :path_prefix => 'permissions'
  map.permissions "permissions", :controller => "role_permissions"
  
  # society_configurations
  map.resources :society_activity_sectors
  map.resources :services
  map.resource :society_identity_configuration, :controller => 'society_identity_configuration'
  map.society_configurations "society_configurations", :controller => "society_identity_configuration", :action => "show"
  
  # security
  map.resource :password_policies, :controller => 'password_policies'
  
  # menus
  map.resources :menus
  map.move_up_menu 'menus/:id/move_up',     :controller => "menus", 
                                            :action     => "move_up", 
                                            :conditions => { :method => :get }
  map.move_down_menu 'menus/:id/move_down', :controller => "menus", 
                                            :action     => "move_down", 
                                            :conditions => { :method => :get }
  
  # others
  map.resources :users
  map.resources :roles
  map.resources :features
  
  # default page for admin section
  map.admin 'admin', :controller => 'users'
end
