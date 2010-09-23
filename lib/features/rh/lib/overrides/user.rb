require_dependency 'app/models/user'

class User
  has_one :employee
  has_many :checkings
  
  has_search_index  :additional_attributes => { :expired? => :boolean },
                    :only_attributes       => [ :username, :enabled, :last_connection, :last_activity ]

  def employee_name
    self.employee ? self.employee.fullname : self.username
  end

  def can_be_destroyed?
    self.employee.nil?
  end
end
