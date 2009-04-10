ActionController::Routing::Routes.add_routes do |map|
  map.resources :contents do |content|
    content.resources :content_versions
  end
end
