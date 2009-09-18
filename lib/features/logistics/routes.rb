ActionController::Routing::Routes.add_routes do |map|
  map.resources :commodities
  map.resources :consumables
  map.refresh_measure_commodity 'commodities/refresh_measure', :controller => 'commodities', :action => 'refresh_measure'
  map.refresh_measure_consumable 'consumables/refresh_measure', :controller => 'consumables', :action => 'refresh_measure'
  map.resources :commodity_categories
  map.resources :consumable_categories
  map.commodities_manager "commodities_manager", :controller => "commodities_manager"
  map.consumables_manager "consumables_manager", :controller => "consumables_manager"
  map.resources :restockable_supplies
  map.resources :stock_inputs
  map.resources :stock_outputs
  map.refresh_suppliers_stock_input 'stock_inputs/refresh_suppliers', :controller => 'stock_inputs', :action => 'refresh_suppliers'
  map.refresh_suppliers_stock_output 'stock_outputs/refresh_suppliers', :controller => 'stock_outputs', :action => 'refresh_suppliers'
  map.refresh_suppliers_stock_input 'stock_inputs/refresh_infos', :controller => 'stock_inputs', :action => 'refresh_infos'
  map.resources :inventories

  map.stock_manager "stock_manager", :controller => "stock_inputs" #default page for stock manager
  map.logistics 'logistics', :controller => 'commodities_manager' #default page for logistics
end

