ActionController::Routing::Routes.add_routes do |map|
  map.resources :products
  map.resources :produts_catalog
  map.resources :product_references
  map.resources :product_reference_categories do |product_reference_category|
    product_reference_category.resources :product_reference_categories
    product_reference_category.resources :product_references do |product_reference|
      product_reference.resources :products
    end
  end
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
  #  map.connect 'products', :controller => 'products_catalog' #default page for products
end