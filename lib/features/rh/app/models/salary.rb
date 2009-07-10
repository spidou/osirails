class Salary < ActiveRecord::Base
  has_permissions :as_business_object

  # Relationships
  belongs_to :job_contract
  
  validates_numericality_of :gross_amount
  
  RATIO_FOR_NET_AMOUNT = 0.3
  
  # method that return the net amount of the salary
  def net_amount
    self.gross_amount -= self.gross_amount * RATIO_FOR_NET_AMOUNT
  end
end
