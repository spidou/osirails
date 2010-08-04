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
      return 0.0 if unit_price.nil?
      return unit_price if prizegiving.nil? or prizegiving.zero?
      unit_price / ( 1 + ( prizegiving / 100 ) )
    end
    
    def total
      return 0.0 if unit_price_with_prizegiving.zero? or quantity.nil? or quantity.zero?
      unit_price_with_prizegiving * quantity
    end
    
    def total_with_taxes
      return total if vat.nil? or vat.zero?
      total * ( 1 + ( vat / 100.0 ) ) # TODO test that modification
    end
  end
  
end
