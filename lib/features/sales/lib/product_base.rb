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
      unit_price * ( 1 - ( prizegiving / 100 ) ) #see here http://fr.wikipedia.org/wiki/Pourcentage#Pourcentage_d.27augmentation_et_de_r.C3.A9duction
    end
    
    def total
      return 0.0 if unit_price.nil? or quantity.nil?
      unit_price_with_prizegiving * quantity
    end
    
    #TODO test this method
    def taxes
      return 0.0 if vat.nil? or vat.zero?
      total * vat / 100.0
    end
    
    #TODO test this method
    def total_with_taxes
      total + taxes
    end
  end
  
end
