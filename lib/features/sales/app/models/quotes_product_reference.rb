class QuotesProductReference < ActiveRecord::Base
  acts_as_list
  
  belongs_to :quote
  belongs_to :product_reference
  
  validates_presence_of :name, :description, :quantity, :unit_price, :vat
  validates_numericality_of :quantity, :unit_price, :vat
  
  # define if the object should be destroyed (after clicking on the remove button via the web site)
  attr_accessor :should_destroy
  
  attr_protected :original_name, :original_description, :original_unit_price
  
  before_save :default_discount
  
  def default_discount
    self.discount ||= 0.to_f
  end
  
  def unit_price_with_discount
    return 0 if unit_price.nil?
    return unit_price if discount.nil? or discount == 0 
    unit_price - ( unit_price * (discount / 100) )
  end
  
  def total
    return 0.to_f if unit_price_with_discount.nil? or quantity.nil?
    unit_price_with_discount * quantity
  end
  
  def total_with_taxes
    return total if vat.nil? or vat == 0
    total + ( total * ( vat / 100 ) )
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
