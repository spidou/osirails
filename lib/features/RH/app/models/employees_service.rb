class EmployeesService < ActiveRecord::Base
  belongs_to :employee
  belongs_to :service
  
  def responsable(service)
    tmp = self.find(:all,:conditions => ["service_id=? ,responsable=?",service,true ])
    manager = Employee.find(tmp.employee_id)
    return manager
  end
  
end
