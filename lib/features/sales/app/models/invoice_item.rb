class InvoiceItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :invoice
  belongs_to :product
  
  acts_as_list :scope => :invoice
  
  def unit_price
    product ? product.unit_price : nil
  end
  
  def vat
    product ? product.vat : nil
  end
end
