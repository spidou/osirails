class Estimate < ActiveRecord::Base
  # Relationships
  belongs_to :step_estimate
  has_many :estimates_product_references
  
  # Callbacks
  after_create :default_validity_date
  
  # Validations
  validates_numericality_of [:reduction, :carriage_costs, :account], :allow_nil => false
  
  def default_validity_date
    self.validity_date = self.created_at + 1.month
    self.save
  end
  
  def product_references
    self.estimates_product_references.collect { |epr| epr.product_reference }
  end
  
  def total
    result = 0
    self.estimates_product_references.each { |epr| result += epr.amount }
    result
  end
  
  def net
    total - self.reduction + self.carriage_costs
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