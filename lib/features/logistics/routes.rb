ActionController::Routing::Routes.add_routes do |map|
  ### STOCKS
  map.resources :commodities
  map.resources :consumables
  
  map.resources :commodity_categories
  map.resources :consumable_categories
  
  map.resources :commodity_sub_categories
  map.resources :consumable_sub_categories
  
  map.with_options :name_prefix => '', :conditions => { :method => :get } do |m|
    m.disable_commodity   'commodities/:id/disable',  :controller => 'commodities', :action => 'disable'
    m.disable_consumable  'consumables/:id/disable',  :controller => 'consumables', :action => 'disable'
    m.enable_commodity    'commodities/:id/enable',   :controller => 'commodities', :action => 'enable'
    m.enable_consumable   'consumables/:id/enable',   :controller => 'consumables', :action => 'enable'
    
    m.disable_commodity_category      'commodity_categories/:id/disable',       :controller => 'commodity_categories',      :action => 'disable'
    m.disable_commodity_sub_category  'commodity_sub_categories/:id/disable',   :controller => 'commodity_sub_categories',  :action => 'disable'
    
    m.disable_consumable_category     'consumable_categories/:id/disable',      :controller => 'consumable_categories',     :action => 'disable'
    m.disable_consumable_sub_category 'consumable_sub_categories/:id/disable',  :controller => 'consumable_sub_categories', :action => 'disable'
    
    m.enable_commodity_category       'commodity_categories/:id/enable',        :controller => 'commodity_categories',      :action => 'enable'
    m.enable_commodity_sub_category   'commodity_sub_categories/:id/enable',    :controller => 'commodity_sub_categories',  :action => 'enable'
    
    m.enable_consumable_category      'consumable_categories/:id/enable',       :controller => 'consumable_categories',     :action => 'enable'
    m.enable_consumable_sub_category  'consumable_sub_categories/:id/enable',   :controller => 'consumable_sub_categories', :action => 'enable'
  end
  
  map.commodities_manager 'commodities_manager', :controller => 'commodities_manager'
  map.consumables_manager 'consumables_manager', :controller => 'consumables_manager'
 
  map.resources :restockable_supplies
  
  map.resources :inventories
  
  map.resources :stock_inputs
  map.resources :stock_outputs
  
  # AJAX REQUESTS
  map.update_supply_stock_infos 'stock_inputs/update_supply_stock_infos', :controller => 'stock_inputs',  :action => 'update_supply_stock_infos'
  
  map.update_commodity_sub_categories   'update_commodity_sub_categories',  :controller => 'commodity_categories',  :action => 'update_supply_sub_categories'
  map.update_consumable_sub_categories  'update_consumable_sub_categories', :controller => 'consumable_categories', :action => 'update_supply_sub_categories'
  
  map.update_commodity_unit_measure   'update_commodity_unit_measure',  :controller => 'commodity_sub_categories',  :action => 'update_supply_unit_measure'
  map.update_consumable_unit_measure  'update_consumable_unit_measure', :controller => 'consumable_sub_categories', :action => 'update_supply_unit_measure'
  
  map.update_commodity_supply_sizes   'update_commodity_supply_sizes',  :controller => 'commodities', :action => 'update_supplies_supply_sizes'
  map.update_consumable_supply_sizes  'update_consumable_supply_sizes', :controller => 'consumables', :action => 'update_supplies_supply_sizes'
  
  map.stock_manager 'stock_manager', :controller => 'stock_inputs' #default page for stock manager
  
  ### LOGISTICS
  map.resources :tools

  [:computers, :devices, :machines, :vehicles, :other_tools].each do |tool_type|
    map.resources tool_type do |tool|
      tool.resources :tool_events
    end
  end
  
  map.equipments_calendar 'equipments_calendar/:id_or_name/:period/:year/:month/:day',
                          :controller   => 'equipments_calendar',
                          :action       => 'show',
                          :id_or_name   => 'equipments_calendar',
                          :period       => 'month',
                          :year         => nil,
                          :month        => nil,
                          :day          => nil,
                          :requirements => { :period => /(day|week|month)/,
                                             :year   => /(19|20)\d\d/,
                                             :month  => /(0?[1-9]|1[012])/,
                                             :day    => /(0?[1-9]|[1|2]\d|3[01])/ }
  
  map.stocks    'stocks',    :controller => 'commodities_manager' #default page for stocks
  map.logistics 'logistics', :controller => 'tools'               #default page for logistics
end

