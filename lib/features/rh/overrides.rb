require_dependency 'user'
require_dependency 'service'

class User
  belongs_to :employee

  def employee_name
    self.employee ? self.employee.fullname : self.username
  end

  def can_be_destroyed?
    self.employee.nil?
  end
end

class Service
  has_many :employees_services
  has_many :employees, :through => :employees_services

  def can_be_destroyed?
    self.employees.empty? and self.children.empty?
  end
end

module ApplicationHelper
  def display_welcome_message
    "Bienvenue, " + (current_user.employee.nil? ? current_user.username : current_user.employee.fullname)
  end
end
