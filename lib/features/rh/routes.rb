ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
    employee.resources :leaves
  end
  
  map.resources :jobs
  map.resources :job_contracts
  map.resources :checkings
  
  map.resources :leave_requests
  map.check_leave_request 'check/:id', :controller => 'leave_requests', :action => 'check', :conditions => { :method => :put }
  map.notice_leave_request 'notice/:id', :controller => 'leave_requests', :action => 'notice', :conditions => { :method => :put }
  map.close_leave_request 'close/:id', :controller => 'leave_requests', :action => 'close', :conditions => { :method => :put }
  map.accepted_leave_requests 'accepted_leave_requests', :controller => 'leave_requests', :action => 'accepted', :conditions => { :method => :get }
  map.refused_leave_requests 'refused_leave_requests', :controller => 'leave_requests', :action => 'refused', :conditions => { :method => :get }
  map.cancelled_leave_requests 'cancelled_leave_requests', :controller => 'leave_requests', :action => 'cancelled', :conditions => { :method => :get }
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
