ActionController::Routing::Routes.add_routes do |map|
  map.received_memorandums 'received_memorandums', :controller => 'received_memorandums', :action => "index"
  map.received_memorandum 'received_memorandums/:id', :controller => 'received_memorandums', :action => "show"
  
  map.resources :memorandums, :controller => 'sended_memorandums'
  
  map.memorandums 'memorandums', :controller => 'received_memorandums' # default page for memorandum
end
