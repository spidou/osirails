require_dependency 'app/models/user'

class User
  has_one :employee
  
  journalize :identifier_method => :employee_name # this is an override to define a new identifier method
  
  acts_as_watcher :identifier_method => :employee_name, :email_method => :employee_email # this is an override to define a new identifier method and email method
  
  has_many :checkings
  
  has_search_index  :additional_attributes => { :expired? => :boolean },
                    :only_attributes       => [ :username, :enabled, :last_connection, :last_activity ]

  def employee_name
    employee ? employee.fullname : username
  end
  
  def employee_email
    employee ? employee.intranet_email : nil
  end

  def can_be_destroyed?
    employee.nil?
  end
end
