ActionController::Routing::Routes.add_routes do |map|
  map.resources :employees do |employee|
    employee.resources :salaries
    employee.resources :premia
    employee.resource :job_contract
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
  
  map.rh 'rh', :controller => 'employees' #default page for human resources
end
