ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
  end
  map.resources :jobs
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
