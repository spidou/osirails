# module to gather methods used in product.rb and quote_item.rb
# any model which has the following methods can implement that module :
#   - unit_price
#   - prizegiving
#   - vat
#   - quantity
module ProductBase
  
  class << self
    def included base #:nodoc:
      base.send :include, InstanceMethods
    end
  end
  
  module InstanceMethods
    def unit_price_with_prizegiving
      return 0.0 if unit_price.nil? or unit_price.zero?
      unit_price.to_f * ( 1.0 - ( prizegiving.to_f / 100.0 ) )
    end
    
    def total
      return 0.0 if unit_price.nil? or quantity.nil?
      unit_price * quantity
    end
    
    def total_with_prizegiving
      return 0.0 if quantity.nil?
      unit_price_with_prizegiving * quantity
    end
    
    def total_with_taxes
      return total_with_prizegiving if vat.nil? or vat.zero?
      total_with_prizegiving * ( 1 + ( vat / 100.0 ) )
    end
  end
  
end
