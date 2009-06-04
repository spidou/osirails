ActionController::Routing::Routes.add_routes do |map|
  map.attachment 'attachments/:id/:style', :controller => 'attachments', :action => 'show', 
                                           :requirements => { :style => /(original|thumb|medium)/ },
                                           :style => nil
end

Document.documents_owners.each do |owner|
  ActionController::Routing::Routes.add_routes do |map|
    map.resources owner.name.tableize.to_sym do |owner|
      owner.resources :documents
    end
  end
end
