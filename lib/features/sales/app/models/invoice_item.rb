class InvoiceItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :invoice
  belongs_to :product
  
  acts_as_list :scope => :invoice
  
  validates_numericality_of :unit_price, :vat, :if => :product
  
  named_scope :product_items, :conditions => [ 'product_id IS NOT NULL' ]
  named_scope :free_items,    :conditions => [ 'product_id IS NULL' ]
  
  def unit_price
    product ? product.unit_price : super
  end
  
  def vat
    product ? product.vat : super
  end
end
