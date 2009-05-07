ActionController::Routing::Routes.add_routes do |map|
  map.resources :products
  map.resources :produts_catalog
  map.resources :product_references do |product_reference|
    product_reference.resources :products
  end
  map.resources :product_reference_categories do |product_reference_category|
    product_reference_category.resources :product_reference_categories
    product_reference_category.resources :product_references do |product_reference|
      product_reference.resources :products
    end
  end
  map.product_reference_manager "product_reference_manager", :controller => "product_reference_manager"
  map.goods 'goods', :controller => 'products_catalog' #default page for products
  
  map.auto_complete_for_product_reference_name 'auto_complete_for_product_reference_name',
                                                 :controller => 'product_references',
                                                 :action => 'auto_complete_for_product_reference_name',
                                                 :method => :get
end
