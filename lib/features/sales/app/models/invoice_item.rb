class InvoiceItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :invoice
  belongs_to :end_product
  
  validates_numericality_of :unit_price, :quantity, :vat, :if => Proc.new{ |i| (i.unit_price and i.unit_price > 0) or (i.quantity and i.quantity > 0) or (i.vat and i.vat > 0) }
  
  validates_presence_of :name, :unless => :should_destroy? # don't validate if it's a free_item marked for destroy (because only free_item use the should_destroy accessor)
  
  named_scope :product_items, :conditions => [ 'end_product_id IS NOT NULL' ]
  named_scope :free_items,    :conditions => [ 'end_product_id IS NULL' ]
  
  attr_accessor :should_destroy
  
  # should_destroy accessor is only used for free_item, and quantity.zero? is used for product_item
  def should_destroy?
    ( end_product_id and quantity.zero? ) or ( end_product_id.nil? and should_destroy.to_i == 1 )
  end
  
  def free_item?
    end_product.nil?
  end
  
  def name
    end_product ? end_product.name : super
  end
  
  def description
    end_product ? end_product.description : super
  end
  
  def unit_price
    end_product ? end_product.unit_price : super
  end
  
  def vat
    end_product ? end_product.vat : super
  end
  
  def prizegiving
    end_product.prizegiving if end_product
  end
  
  def position # used for sorted_invoice_items
    super || 0
  end
end
