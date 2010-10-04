ActionController::Routing::Routes.add_routes do |map|
  map.search 'search' , :controller => 'advanced_search'
  map.connect 'search_index/update', :controller => 'search_indexes', :action => 'update', :conditions => { :method => :post }
  map.resources :queries
  map.connect 'queries/new', :controller => 'queries', :action => 'new', :conditions => {:method => :post}
  map.connect 'queries/:id/edit', :controller => 'queries', :action => 'edit', :conditions => {:method => :post}
end
