ActionController::Routing::Routes.add_routes do |map|
  map.attachment 'attachments/:id/:style', :controller => 'attachments', :action => 'show', 
                                           :requirements => { :style => /(original|thumb|medium|large)/ },
                                           :style => nil
end

Document.documents_owners.each do |owner|
  ActionController::Routing::Routes.add_routes do |map|
    owner_name = owner.name.underscore
    map.resources "#{owner_name}_documents".to_sym, :controller => "documents"
  end
end
