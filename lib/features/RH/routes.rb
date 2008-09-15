ActionController::Routing::Routes.add_routes do |map|
  ### HUMAN RESOURCES
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
  end
  map.resources :jobs
  
  map.connect 'rh', :controller => 'employees' #default page for human resources
  ### END HUMAN RESOURCES
end