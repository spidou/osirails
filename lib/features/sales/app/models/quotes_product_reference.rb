class QuotesProductReference < ActiveRecord::Base
  belongs_to :quote
  belongs_to :product_reference
  
  def amount
    unit_price * quantity
  end
  
  def amount_with_taxes
    amount + amount / 100 * ConfigurationManager.sales_taxes_vat
  end
end
