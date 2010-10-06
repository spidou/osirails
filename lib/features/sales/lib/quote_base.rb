# module to gather methods used in quote.rb and quotation.rb
# any model which has the following methods can implement that module :
#   - total
#   - net
#   - total_with_taxes
#   - summon_of_taxes
#   - net_to_paid
#   - tax_coefficients
module QuoteBase
  
  class << self
    def included base #:nodoc:
      base.send :include, InstanceMethods
    end
  end
  
  module InstanceMethods
  
    def total
      product_quote_items.collect(&:total).sum
    end
    
    def total_with_prizegiving
      product_quote_items.collect(&:total_with_prizegiving).sum
    end
    
    def net
      prizegiving = self.prizegiving || 0.0
      total_with_prizegiving * ( 1 - ( prizegiving / 100 ) )
    end
    
    def total_with_taxes
      product_quote_items.collect(&:total_with_taxes).sum
    end
    
    def summon_of_taxes
      total_with_taxes - total
    end
    
    def net_to_paid
      carriage_costs = self.carriage_costs || 0.0
      discount = self.discount || 0.0
      net + carriage_costs + summon_of_taxes - discount
    end
    
    def tax_coefficients
      product_quote_items.collect(&:vat).uniq
    end
    
    def total_taxes_for(coefficient)
      product_quote_items.select{ |i| i.vat == coefficient }.collect(&:total).sum
    end
  end
  
end
