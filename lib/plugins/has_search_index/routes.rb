ActionController::Routing::Routes.add_routes do |map|
  map.search 'search' , :controller => 'advanced_search'
  map.resources :queries
  
  map.new_query  'queries/new',      :controller => 'queries', :action => 'new',   :conditions => { :method => :post }
  map.edit_query 'queries/:id/edit', :controller => 'queries', :action => 'edit',  :conditions => { :method => :post }
end
