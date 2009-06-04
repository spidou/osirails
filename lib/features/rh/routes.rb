ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
  end
  
  map.resources :jobs
  map.job_contracts 'job_contracts', :controller => 'job_contracts', :action => 'index' #FIXME remove that line once the url_for_menu helper is upgraded!
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
