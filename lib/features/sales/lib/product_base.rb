# module to gather methods used in product.rb and quote_item.rb
# any model which has the following methods can implement that module :
#   - unit_price
#   - discount
#   - vat
#   - quantity
module ProductBase
  
  class << self
    def included base #:nodoc:
      base.send :include, InstanceMethods
    end
  end
  
  module InstanceMethods
    def unit_price_with_discount
      return 0.to_f if unit_price.nil?
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
  end
  
end
