ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource  :job_contract, :controller => 'job_contract'
    employee.resources :leaves
    employee.cancel_employee_leave 'leaves/:id/cancel', :controller => 'leaves',
                                                        :action => 'cancel',
                                                        :name_prefix => '',
                                                        :conditions => { :method => :get }
  end
  
  map.resources :jobs
  
  map.resources :checkings
  map.with_options :controller => 'checkings' do |checking|
    checking.override_form_checking 'checkings/:id/override_form',  :action => 'override_form', :conditions => { :method => :get }
    checking.override_checking      'checkings/:id/override',       :action => 'override',      :conditions => { :method => :put }
    checking.cancel_checking        'checkings/:id/cancel',         :action => 'cancel',        :conditions => { :method => :get }
  end
  
  map.resources :leave_requests
  map.with_options :controller => 'leave_requests', :conditions => { :method => :get } do |l|
    l.accepted_leave_requests   'accepted_leave_requests',        :action => 'accepted'
    l.refused_leave_requests    'refused_leave_requests',         :action => 'refused'
    l.cancelled_leave_requests  'cancelled_leave_requests',       :action => 'cancelled'
    l.leave_request_check_form  'leave_requests/:id/check_form',  :action => 'check_form'
    l.leave_request_notice_form 'leave_requests/:id/notice_form', :action => 'notice_form'
    l.leave_request_close_form  'leave_requests/:id/close_form',  :action => 'close_form'
    l.cancel_leave_request      'leave_requests/:id/cancel',      :action => 'cancel'
  end
  
  map.with_options :controller => 'leave_requests', :conditions => { :method => :put } do |l|
    l.check_leave_request   'leave_requests/:id/check',  :action => 'check'
    l.notice_leave_request  'leave_requests/:id/notice', :action => 'notice'
    l.close_leave_request   'leave_requests/:id/close',  :action => 'close'
  end
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
