class Premium < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :employee_sensitive_data
  
  validates_numericality_of :amount
  
  validates_presence_of :date
  validates_presence_of :remark
end
