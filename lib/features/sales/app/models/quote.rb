class Quote < ActiveRecord::Base
  # Relationships
  belongs_to :step_estimate
  has_many :quotes_product_references
  has_many :product_references, :through => :quotes_product_references
  
  # Validations
  validates_presence_of :step_estimate_id
  validates_numericality_of [:reduction, :carriage_costs, :account], :allow_nil => false
  
  def total
    result = 0
    product_references.each { |epr| result += epr.amount }
    result
  end
  
  def net
    total - reduction + carriage_costs
  end
  
  def total_with_taxes
    total + total / 100 * ConfigurationManager.sales_taxes_vat
  end
  
  def summon_of_taxes
    self.total_with_taxes - self.total
  end
  
  def net_to_paid
    total_with_taxes - self.account
  end
end
