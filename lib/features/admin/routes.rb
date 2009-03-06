ActionController::Routing::Routes.add_routes do |map|
  # begin | To create the url architecture "/permissions/*"
  map.resources :business_object_permissions, :path_prefix => 'permissions'
  map.resources :menu_permissions, :path_prefix => 'permissions'
  map.resources :role_permissions, :path_prefix => 'permissions'
  map.resources :document_type_permissions, :path_prefix => 'permissions'
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
end
