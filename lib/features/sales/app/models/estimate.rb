class Estimate < ActiveRecord::Base
  belongs_to :step_estimate
  has_many :estimates_product_references
  
  def product_references
    self.estimates_product_references.collect { |epr| epr.product_reference }
  end
end