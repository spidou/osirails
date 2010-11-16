ActionController::Routing::Routes.add_routes do |map|
  map.search 'search' , :controller => 'advanced_search'
  #map.connect 'search_index/update', :controller => 'search_indexes', :action => 'update', :conditions => { :method => :post } # I commented this line because I didn't find where it is used
  
  map.resources :queries
  
  map.new_query  'queries/new',      :controller => 'queries', :action => 'new',   :conditions => { :method => :post }
  map.edit_query 'queries/:id/edit', :controller => 'queries', :action => 'edit',  :conditions => { :method => :post }
end
