class InvoiceItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :invoice
  belongs_to :product
  
  acts_as_list :scope => :invoice
  
  validates_numericality_of :unit_price, :quantity, :vat, :if => Proc.new{ |i| (i.unit_price and i.unit_price > 0) or (i.quantity and i.quantity > 0) or (i.vat and i.vat > 0) }
  
  validates_presence_of :name, :unless => :should_destroy? # don't validate if it's a free_item marked for destroy (because only free_item use the should_destroy accessor)
  
  named_scope :product_items, :conditions => [ 'product_id IS NOT NULL' ]
  named_scope :free_items,    :conditions => [ 'product_id IS NULL' ]
  
  attr_accessor :should_destroy
  
  # should_destroy accessor is only used for free_item, and quantity.zero? is used for product_item
  def should_destroy?
    ( product_id and quantity.zero? ) or ( product_id.nil? and should_destroy.to_i == 1 )
  end
  
  def name
    product ? product.name : super
  end
  
  def description
    product ? product.description : super
  end
  
  def unit_price
    product ? product.unit_price : super
  end
  
  def vat
    product ? product.vat : super
  end
  
  def prizegiving
    product.prizegiving if product
  end
end
