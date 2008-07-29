class Employee < ActiveRecord::Base
  has_one :user
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end
end
