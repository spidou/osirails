ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
  end
  
  map.resources :jobs
  map.resources :job_contracts
  
  map.resources :leave_requests
  map.accepted_leave_requests 'accepted_leave_requests', :controller => 'leave_requests', :action => 'accepted'
  map.refused_leave_requests 'refused_leave_requests', :controller => 'leave_requests', :action => 'refused'
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
