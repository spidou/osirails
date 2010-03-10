ActionController::Routing::Routes.add_routes do |map|
  map.contact_avatar 'contacts/:id/avatar', :controller => 'contact_avatars', :action => 'show'
end

Contact.contacts_owners_models.each do |owner|
  ActionController::Routing::Routes.add_routes do |map|
    map.resources owner.name.tableize.to_sym do |owner|
      owner.resources :contacts
    end
  end
end
