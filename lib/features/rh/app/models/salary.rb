class Salary < ActiveRecord::Base
  has_permissions :as_business_object

  belongs_to :job_contract
  
  validates_numericality_of :gross_amount, :net_amount
  validates_presence_of :date
end
