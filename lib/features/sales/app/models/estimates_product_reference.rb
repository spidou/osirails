class EstimatesProductReference < ActiveRecord::Base
  # Relationships
  belongs_to :estimate, :foreign_key => 'estimate_id'
  belongs_to :product_reference, :foreign_key => 'product_reference_id'

  # Validations
  validates_presence_of :estimate_id, :product_reference_id
  
  def amount
    unit_price * quantity
  end
  
  def amount_with_taxes
    amount + amount / 100 * ConfigurationManager.sales_taxes_vat
  end
end