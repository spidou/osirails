ActionController::Routing::Routes.add_routes do |map|
  map.resources :memorandums, :controller => 'sended_memorandums'
  map.resources :sended_memorandums
  map.resources :received_memorandums
  map.connect 'memorandums', :controller => 'received_memorandums' # default page for memorandum
end
