require_dependency 'app/models/user'

class User
  has_one :employee
  
  journalize :identifier_method => :employee_name
  
  has_many :checkings
  
  has_search_index  :additional_attributes => { :expired? => :boolean },
                    :only_attributes       => [ :username, :enabled, :last_connection, :last_activity ],
                    :displayed_attributes  => [ :id, :username, :enabled, :expired?, :last_activity ],
                    :main_model            => true

  def employee_name
    self.employee ? self.employee.fullname : self.username
  end

  def can_be_destroyed?
    self.employee.nil?
  end
end
