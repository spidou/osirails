class QuoteItem < ActiveRecord::Base
  include ProductBase
  
  acts_as_list
  
  belongs_to :quote
  belongs_to :product
  
  validates_presence_of :name, :description, :dimensions
  
  validates_numericality_of :unit_price, :vat, :quantity
  validates_numericality_of :discount, :allow_blank => true
  
  validates_associated :product
  
  attr_accessor :should_destroy, :order_id
  
  after_save :save_product
  
  after_destroy :destroy_product
  
  def initialize(*params)
    super(*params)
    self.order_id = quote.order_id if quote
  end
  
  def after_find
    self.order_id = quote.order_id
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def product_attributes=(attributes)
    if attributes[:id].blank?
      self.product = Order.find(order_id).products.build(attributes)
    else
      self.product = Order.find(order_id).products.detect{ |p| p.id == attributes[:id].to_i }
      self.product.attributes = attributes
    end
  end
  
  def save_product
    product.save(false)
  end
  
  # destroy associated product unless quote is already destroyed
  def destroy_product
    product.destroy if Quote.find_by_id(quote.id)
  end
  
  def original_name
    product ? product.product_reference.name : nil
  end
  
  def original_description
    product ? product.product_reference.description : nil
  end
  
  def original_vat
    product ? product.product_reference.vat : nil
  end
  
end
