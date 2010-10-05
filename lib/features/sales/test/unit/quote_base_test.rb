module QuoteBaseTest
  
  class << self
    def included base
      base.class_eval do
      
        #TODO test with real values to assert_equal and with contexts
        
        should "have a correct 'net' value" do
          assert_equal @quote.net, @quote.total*(1-(@quote.prizegiving/100))
        end
        
        should "have a correct 'net_to_paid' value" do
          assert_equal @quote.net_to_paid, @quote.net + @quote.carriage_costs + @quote.summon_of_taxes - @quote.discount
        end
        
        should "have a correct 'tax_coefficients' value" do
          assert_equal @quote.tax_coefficients, @quote.quote_items.collect{ |i| i.vat }.uniq
        end
        
        should "have a correct 'total_taxes_for' value" do
          @quote.tax_coefficients.each do |coefficient|
            assert_equal @quote.total_taxes_for(coefficient), @quote.quote_items.select{ |i| i.vat == coefficient}.collect(&:total).sum
          end  
        end
        
      end
    end
  end
  
end
