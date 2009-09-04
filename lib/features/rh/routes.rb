ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource  :job_contract, :controller => 'job_contract'
    employee.resources :leaves
  end
  
  map.with_options :controller => 'leaves' do |leave|
    leave.cancel_employee_leave 'employees/:employee_id/leaves/:id/cancel', :action => 'cancel', :conditions => {:method => :get}
  end
  
  map.resources :jobs
  
  map.with_options :controller => 'checkings' do |checking|
    checking.override_form_checking 'checkings/:id/override_form',  :action => 'override_form', :conditions => {:method => :get}
    checking.override_checking      'checkings/:id/override',       :action => 'override',      :conditions => {:method => :put}
    checking.cancel_checking        'checkings/:id/cancel',         :action => 'cancel',        :conditions => {:method => :get}
  end
  
  map.resources :checkings
  
  map.resources :leave_requests
  
  map.accepted_leave_requests   'accepted_leave_requests',  :controller => 'leave_requests', :action => 'accepted',   :conditions => { :method => :get }
  map.refused_leave_requests    'refused_leave_requests',   :controller => 'leave_requests', :action => 'refused',    :conditions => { :method => :get }
  map.cancelled_leave_requests  'cancelled_leave_requests', :controller => 'leave_requests', :action => 'cancelled',  :conditions => { :method => :get }
  map.leave_request_check_form  'leave_requests/:id/check_form',  :controller => 'leave_requests', :action => 'check_form',  :conditions => { :method => :get }
  map.leave_request_notice_form 'leave_requests/:id/notice_form', :controller => 'leave_requests', :action => 'notice_form', :conditions => { :method => :get }
  map.leave_request_close_form  'leave_requests/:id/close_form',  :controller => 'leave_requests', :action => 'close_form',  :conditions => { :method => :get }
  map.check_leave_request       'leave_requests/:id/check',  :controller => 'leave_requests', :action => 'check',  :conditions => { :method => :put }
  map.notice_leave_request      'leave_requests/:id/notice', :controller => 'leave_requests', :action => 'notice', :conditions => { :method => :put }
  map.close_leave_request       'leave_requests/:id/close',  :controller => 'leave_requests', :action => 'close',  :conditions => { :method => :put }
  map.cancel_leave_request      'leave_requests/:id/cancel',  :controller => 'leave_requests', :action => 'cancel',  :conditions => { :method => :get }
  
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
