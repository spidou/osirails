class Estimate < ActiveRecord::Base
  belongs_to :step_estimate
  has_many :estimates_product_references
  
  def product_references
    self.estimates_product_references.collect { |epr| epr.product_reference }
  end
  
  def total
    result = 0
    self.estimates_product_references.each { |epr| result += epr.amount }
    result
  end
  
  def total_with_taxes
    total + total / 100 * ConfigurationManager.sales_taxes_vat
  end
  
  def summon_of_taxes
    self.total_with_taxes - self.total
  end
end